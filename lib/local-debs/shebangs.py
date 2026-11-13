import os
from pathlib import Path
import re
import shlex
import shutil
import sys


tree = Path(sys.argv[1])
search_path = sys.argv[2]
missing = {}
env = shutil.which("env", path=search_path)
if env is None:
    raise RuntimeError("The installer does not provide env")

for directory, _, filenames in os.walk(tree, followlinks=False):
    for filename in filenames:
        path = Path(directory) / filename
        if path.is_symlink() or not path.stat().st_mode & 0o111:
            continue
        with path.open("rb") as stream:
            if stream.read(2) != b"#!":
                continue
            first_line = stream.readline()
        match = re.fullmatch(rb"[ \t]*([^ \t\r\n]+)([^\r\n]*)\r?\n?", first_line)
        if match is None:
            raise ValueError(f"Invalid script shebang: {path.relative_to(tree)}")
        interpreter = os.fsdecode(match[1])
        arguments = os.fsdecode(match[2])
        # Preserve explicitly pinned or package-local interpreters.
        if not interpreter.startswith(("/bin/", "/usr/bin/", "/usr/local/bin/")):
            if not os.path.isfile(interpreter):
                missing.setdefault(interpreter, path.relative_to(tree))
            continue
        name = Path(interpreter).name
        replacement = shutil.which(name, path=search_path)
        if replacement is None:
            missing.setdefault(name, path.relative_to(tree))
            continue
        if name == "env":
            tokens = shlex.split(arguments)
            if tokens and tokens[0] in ("-S", "--split-string"):
                tokens = tokens[1:]
            if tokens and not tokens[0].startswith("-") and "=" not in tokens[0]:
                command = shutil.which(tokens[0], path=search_path)
                if command is None:
                    missing.setdefault(tokens[0], path.relative_to(tree))
                elif len(tokens) == 1:
                    replacement, arguments = command, ""
                else:
                    replacement = env
                    arguments = " -S " + shlex.join([command, *tokens[1:]])
        new_line = b"#!" + os.fsencode(replacement + arguments) + b"\n"
        with path.open("rb") as stream:
            stream.readline()
            contents = stream.read()
        path.write_bytes(new_line + contents)

for interpreter, example in sorted(missing.items()):
    print(
        f"Warning: script interpreter {interpreter!r} is not provided "
        f"(e.g. {example}); add its provider to "
        "programs.localDebInstaller.extraRuntimeLibs.",
        file=sys.stderr,
    )
