import base64
import pathlib
import socket
import subprocess
import sys
import tempfile
import threading


def serve(listener, errors):
    try:
        connection, _ = listener.accept()
        with connection:
            connection.settimeout(10)
            stream = connection.makefile("rwb", buffering=0)
            capabilities = b"IMAP4rev1 AUTH=XOAUTH2 SASL-IR"
            stream.write(b"* OK [CAPABILITY " + capabilities + b"] mock server\r\n")
            authenticated = False
            while line := stream.readline():
                tag, command, *arguments = line.strip().split()
                command = command.upper()
                if command == b"CAPABILITY":
                    stream.write(b"* CAPABILITY " + capabilities + b"\r\n")
                elif command == b"AUTHENTICATE":
                    assert arguments[0] == b"XOAUTH2", line
                    if len(arguments) == 1:
                        stream.write(b"+ \r\n")
                        response = stream.readline().strip()
                    else:
                        response = arguments[1]
                    decoded = base64.b64decode(response, validate=True)
                    assert decoded == (
                        b"user=work@example.org\x01"
                        b"auth=Bearer synthetic-token\x01\x01"
                    ), decoded
                    authenticated = True
                elif command == b"LIST":
                    assert authenticated, "Listed folders without authentication"
                    stream.write(b'* LIST () "/" "INBOX"\r\n')
                elif command == b"LOGOUT":
                    stream.write(b"* BYE\r\n" + tag + b" OK logout\r\n")
                    break
                else:
                    raise AssertionError(f"Unexpected IMAP command: {line!r}")
                stream.write(tag + b" OK completed\r\n")
            assert authenticated, "mbsync never authenticated with XOAUTH2"
    except Exception as error:
        errors.append(error)


with tempfile.TemporaryDirectory() as directory, socket.socket() as listener:
    listener.bind(("127.0.0.1", 0))
    listener.listen(1)
    listener.settimeout(10)
    pathlib.Path(directory, "mail").mkdir()
    config = pathlib.Path(directory) / "isyncrc"
    config.write_text(
        f"""IMAPAccount mock
Host 127.0.0.1
Port {listener.getsockname()[1]}
User work@example.org
PassCmd "printf synthetic-token"
AuthMechs XOAUTH2
TLSType None

IMAPStore mock-remote
Account mock

MaildirStore mock-local
Path {directory}/mail/
Inbox {directory}/mail/INBOX
SubFolders Verbatim

Channel mock
Far :mock-remote:
Near :mock-local:
Patterns *
"""
    )
    errors = []
    server = threading.Thread(target=serve, args=(listener, errors))
    server.start()
    try:
        result = subprocess.run(
            [sys.argv[1], "--config", str(config), "--list", "mock"],
            capture_output=True,
            text=True,
            timeout=15,
        )
    finally:
        server.join(timeout=11)
    assert not server.is_alive(), "Mock IMAP server did not finish"
    assert result.returncode == 0, result.stdout + result.stderr
    assert not errors, errors
    assert "INBOX" in result.stdout, result.stdout
