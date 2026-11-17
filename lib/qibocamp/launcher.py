import contextlib
import fcntl
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import tempfile
from urllib.parse import parse_qsl, quote, urlencode, urlsplit, urlunsplit
import uuid


class Cancelled(Exception):
    pass


class LauncherError(Exception):
    pass


def read_json(path):
    try:
        with path.open() as stream:
            value = json.load(stream)
    except FileNotFoundError:
        return {}
    if not isinstance(value, dict):
        raise LauncherError(f"Expected a JSON object in {path}")
    return value


def write_json(path, value):
    temporary = path.with_suffix(".tmp")
    try:
        with temporary.open("w") as stream:
            json.dump(value, stream, indent=2)
            stream.write("\n")
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def split_reference(reference):
    source, separator, output = reference.strip().partition("#")
    if not source or source.startswith("-") or any(c.isspace() for c in source):
        raise LauncherError("Enter a flake reference; URL-encode spaces in paths.")
    output = output if separator else "qibocamp-desktop"
    if not re.fullmatch(r"[A-Za-z0-9_.-]+", output):
        raise LauncherError("Select one package output, such as #qibocamp-desktop.")
    if output.startswith("apps."):
        raise LauncherError("Select a package, not an apps output.")
    return source, output


def repository_reference(repository, revision=None, commit=False):
    repository = repository.strip()
    parsed = urlsplit(repository)
    query = dict(parse_qsl(parsed.query))
    github = re.fullmatch(r"github:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository.split("?")[0])
    git = parsed.scheme in {"git+https", "git+ssh"} and parsed.netloc and parsed.path
    if not (github or git) or parsed.fragment or set(query) - {"dir"}:
        raise LauncherError(
            "Use github:owner/repository or a git+https:// or git+ssh:// URL, "
            "optionally with ?dir=..., but without a revision or #output."
        )
    if revision is None:
        return repository
    if not revision or any(c.isspace() for c in revision):
        raise LauncherError("Enter a nonempty branch, tag or commit without spaces.")
    if commit and not re.fullmatch(r"[0-9a-fA-F]{40}", revision):
        raise LauncherError("Enter the full 40-character Git commit ID.")
    query["rev" if commit else "ref"] = revision
    return urlunsplit(parsed._replace(query=urlencode(query)))


class Dialog:
    def show(self, *arguments):
        result = subprocess.run(
            ["zenity", "--title=Qibocamp", *arguments],
            text=True,
            stdout=subprocess.PIPE,
            check=False,
        )
        if result.returncode == 1:
            raise Cancelled()
        if result.returncode != 0:
            raise LauncherError(f"Dialog failed (exit {result.returncode}).")
        return result.stdout.rstrip("\n")

    def entry(self, text, value=""):
        return self.show("--entry", f"--text={text}", f"--entry-text={value}")

    def error(self, text, log):
        result = subprocess.run(
            [
                "zenity", "--error", "--title=Qibocamp",
                f"--text={text}\n\nDiagnostics: {log}", "--no-markup",
                "--extra-button=View log",
            ],
            text=True, stdout=subprocess.PIPE, check=False,
        )
        if result.stdout.strip() == "View log":
            subprocess.run(
                ["zenity", "--text-info", "--title=Qibocamp diagnostics",
                 f"--filename={log}", "--width=900", "--height=600"],
                check=False,
            )

    @contextlib.contextmanager
    def progress(self):
        with subprocess.Popen(
            [
                "zenity", "--progress", "--title=Preparing Qibocamp",
                "--text=Resolving source and building or downloading the package...",
                "--pulsate", "--auto-close", "--percentage=0",
            ],
            stdin=subprocess.PIPE,
        ) as process:
            try:
                yield process
            finally:
                if process.poll() is None:
                    process.communicate(b"100\n")


def terminate(process):
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        process.wait()
        return
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


class Launcher:
    def __init__(self, state, config, dialog):
        self.state = state
        self.config = config
        self.dialog = dialog
        self.history_file = state / "history.json"
        self.repository_file = config / "repository.json"
        self.log = state / "preparation.log"

    def run_nix(self, arguments, progress, refresh=False):
        # --no-write-lock-file would permit in-memory updates despite this check.
        command = [
            "nix", "--option", "accept-flake-config", "false",
            *arguments, "--no-update-lock-file",
        ]
        if refresh:
            command.append("--refresh")
        with self.log.open("a") as log, tempfile.TemporaryFile(mode="w+") as output:
            with subprocess.Popen(
                command, stdin=subprocess.DEVNULL, stdout=output, stderr=log,
                text=True, start_new_session=True,
            ) as process:
                try:
                    while True:
                        if progress.poll() is not None:
                            if progress.returncode != 0:
                                raise Cancelled()
                            raise LauncherError("The preparation dialog closed unexpectedly.")
                        try:
                            status = process.wait(timeout=0.15)
                            break
                        except subprocess.TimeoutExpired:
                            pass
                finally:
                    if process.poll() is None:
                        terminate(process)
            if status != 0:
                raise LauncherError(f"Nix preparation failed (exit {status}).")
            output.seek(0)
            return json.load(output)

    def prepare(self, reference, remember_source=True, refresh=True):
        source, output = split_reference(reference)
        history = read_json(self.history_file)
        root = self.state / f"build-{uuid.uuid4().hex}"
        self.log.write_text(f"Preparing {reference}\n")
        committed = False
        try:
            with self.dialog.progress() as progress:
                metadata = self.run_nix(
                    ["flake", "metadata", "--json", source], progress, refresh=refresh,
                )
                # Build the snapshot, not a local directory that may change meanwhile.
                locked = metadata["url"]
                if metadata["locked"]["type"] == "path":
                    locked = "path:" + quote(metadata["path"], safe="/")
                results = self.run_nix(
                    ["build", "--json", "--out-link", str(root), f"{locked}#{output}^out"],
                    progress,
                )
                if len(results) != 1 or set(results[0]["outputs"]) != {"out"}:
                    raise LauncherError("Expected one package with a single 'out' output.")
                package = Path(results[0]["outputs"]["out"])
                program = package / "bin/qibocamp-desktop"
                if not os.access(program, os.X_OK):
                    raise LauncherError(
                        "The selected package does not provide bin/qibocamp-desktop. "
                        "Use #qibocamp-desktop or #default, not an apps output."
                    )
                if root.resolve() != package or not root.is_symlink():
                    raise LauncherError("Nix did not create the expected retained build.")
                if progress.poll() is not None:
                    raise Cancelled()
                previous = history.get("build", {}).get("root")
                history["build"] = {"root": str(root), "program": str(program)}
                if remember_source:
                    history["source"] = f"{source}#{output}"
                if metadata["locked"].get("rev"):
                    history["commit"] = f"{metadata['url']}#{output}"
                write_json(self.history_file, history)
                committed = True
        finally:
            if not committed:
                root.unlink(missing_ok=True)
        if previous:
            previous = Path(previous)
            if previous.parent == self.state and previous.name.startswith("build-"):
                previous.unlink(missing_ok=True)
        return program

    def last_build(self, history):
        build = history.get("build")
        if not build:
            raise LauncherError("No prepared build yet. Choose a source first.")
        program = Path(build["program"])
        if not os.access(program, os.X_OK):
            self.dialog.show(
                "--question", "--no-markup",
                "--text=The last prepared build is missing. Rebuild the last source?",
                "--ok-label=Rebuild and launch", "--cancel-label=Cancel",
            )
            if not history.get("source"):
                raise LauncherError("No saved source is available. Choose a source first.")
            return self.prepare(history["source"])
        return program

    def menu(self):
        while True:
            history = read_json(self.history_file)
            repository = read_json(self.repository_file).get("repository", "")
            rows = []
            if history.get("build"):
                rows.append((
                    "Launch last prepared build", history["build"]["program"],
                ))
            if history.get("source"):
                rows.append(("Rebuild and launch last source", history["source"]))
            if history.get("commit"):
                rows.append((
                    "Build and launch last resolved Git commit", history["commit"],
                ))
            rows.extend([
                ("Build and launch local checkout", "Select an on-disk flake directory"),
                ("Build and launch repository branch/tag", repository or "Set repository first"),
                ("Build and launch repository commit", repository or "Set repository first"),
                ("Build and launch flake reference", "Full reference; default #qibocamp-desktop"),
                ("Set repository shortcut", repository or "Not configured"),
            ])
            cells = []
            for index, (name, description) in enumerate(rows):
                cells.extend(["TRUE" if index == 0 else "FALSE", name, description])
            action = self.dialog.show(
                "--list", "--width=950", "--height=450", "--no-markup",
                "--radiolist", "--column=Select", "--column=Action",
                "--column=Source", "--print-column=2",
                "--text=Select a package source. Remote references execute trusted code.\n"
                "Preparation requires locked inputs; local paths include untracked files.",
                *cells,
            )
            if action == "Launch last prepared build":
                return self.last_build(history)
            if action == "Rebuild and launch last source":
                if not history.get("source"):
                    raise LauncherError("No saved source. Choose a source first.")
                return self.prepare(history["source"])
            if action == "Build and launch last resolved Git commit":
                if not history.get("commit"):
                    raise LauncherError("No resolved Git commit. Prepare a remote source first.")
                return self.prepare(history["commit"], remember_source=False, refresh=False)
            if action == "Build and launch local checkout":
                directory = self.dialog.show("--file-selection", "--directory")
                path = Path(directory).expanduser().resolve()
                if not (path / "flake.nix").is_file():
                    raise LauncherError("The selected directory does not contain flake.nix.")
                return self.prepare("path:" + quote(str(path), safe="/"))
            if action == "Build and launch flake reference":
                reference = self.dialog.entry("Complete trusted flake package reference:")
                return self.prepare(reference)
            if action == "Set repository shortcut" or action in {
                "Build and launch repository branch/tag", "Build and launch repository commit",
            }:
                if action == "Set repository shortcut" or not repository:
                    repository = repository_reference(self.dialog.entry(
                        "Repository: github:owner/repository or git+https:// / git+ssh:// URL",
                        repository,
                    ))
                if action == "Set repository shortcut":
                    self.config.mkdir(parents=True, exist_ok=True)
                    write_json(self.repository_file, {"repository": repository})
                    continue
                commit = action == "Build and launch repository commit"
                revision = self.dialog.entry(
                    "Full 40-character Git commit ID:" if commit else "Branch or tag:"
                )
                reference = repository_reference(repository, revision, commit)
                self.config.mkdir(parents=True, exist_ok=True)
                write_json(self.repository_file, {"repository": repository})
                return self.prepare(reference, refresh=not commit)
            raise LauncherError("No recognized action selected.")


def main():
    os.umask(0o077)
    state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "qibocamp-launcher"
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "qibocamp-launcher"
    dialog = Dialog()
    launcher = Launcher(state, config, dialog)
    try:
        state.mkdir(parents=True, exist_ok=True)
        with (state / "launcher.lock").open("w") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise LauncherError("Another Qibocamp menu or preparation is already open.")
            program = launcher.menu()
            # The lock is close-on-exec; application windows do not hold it.
            os.execv(str(program), [str(program)])
    except Cancelled:
        return 0
    except (LauncherError, OSError, ValueError, KeyError, TypeError) as error:
        if state.is_dir():
            with launcher.log.open("a") as log:
                log.write(f"\n{error}\n")
        dialog.error(str(error), launcher.log)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
