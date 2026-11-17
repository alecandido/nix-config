import contextlib
import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("launcher", sys.argv.pop(1))
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)

COMMIT = "a" * 40
PINNED = f"github:example/qibocamp/{COMMIT}?narHash=sha256-test"


class FakeDialog:
    def __init__(self):
        self.show = Mock()
        self.entry = Mock()

    @contextlib.contextmanager
    def progress(self):
        yield Mock(poll=Mock(return_value=None))


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.state = self.directory / "state"
        self.state.mkdir()
        self.dialog = FakeDialog()
        self.launcher = launcher.Launcher(
            self.state, self.directory / "config", self.dialog
        )
        self.package = self.directory / "package"
        self.program = self.package / "bin/qibocamp-desktop"
        self.program.parent.mkdir(parents=True)
        self.program.write_text("#!/bin/sh\nexit 0\n")
        self.program.chmod(0o755)
        self.metadata = {
            "url": PINNED,
            "path": str(self.directory / "source"),
            "locked": {"type": "github", "rev": COMMIT},
        }
        self.calls = []
        self.launcher.run_nix = self.fake_nix

    def fake_nix(self, arguments, progress, refresh=False):
        self.calls.append((arguments, refresh))
        if arguments[:2] == ["flake", "metadata"]:
            return self.metadata
        root = Path(arguments[arguments.index("--out-link") + 1])
        root.symlink_to(self.package)
        return [{"outputs": {"out": str(self.package)}}]

    def history(self):
        return launcher.read_json(self.launcher.history_file)

    def test_prepare_pins_remote_and_retains_output(self):
        program = self.launcher.prepare("github:example/qibocamp?ref=main")
        self.assertEqual(program, self.program)
        self.assertTrue(self.calls[0][1])
        self.assertEqual(self.calls[1][0][-1], f"{PINNED}#qibocamp-desktop^out")
        history = self.history()
        self.assertEqual(history["source"], "github:example/qibocamp?ref=main#qibocamp-desktop")
        self.assertEqual(history["commit"], f"{PINNED}#qibocamp-desktop")
        self.assertEqual(Path(history["build"]["root"]).resolve(), self.package)

    def test_local_prepares_snapshot_and_preserves_remote_commit(self):
        self.launcher.prepare("github:example/qibocamp")
        old_root = Path(self.history()["build"]["root"])
        self.metadata = {
            "url": "path:/mutable/checkout?narHash=test",
            "path": "/nix/store/example-source",
            "locked": {"type": "path"},
        }
        self.launcher.prepare("path:/mutable/checkout#default")
        self.assertEqual(self.calls[-1][0][-1], "path:/nix/store/example-source#default^out")
        self.assertEqual(self.history()["commit"], f"{PINNED}#qibocamp-desktop")
        self.assertEqual(self.history()["source"], "path:/mutable/checkout#default")
        self.assertFalse(old_root.exists())

    def test_failed_preparation_preserves_last_build_and_history(self):
        self.launcher.prepare("github:example/qibocamp")
        history = self.history()
        self.program.unlink()
        with self.assertRaisesRegex(launcher.LauncherError, "does not provide"):
            self.launcher.prepare("github:example/other")
        self.assertEqual(self.history(), history)
        self.assertEqual(list(self.state.glob("build-*")), [Path(history["build"]["root"])])

    def test_cancelled_preparation_preserves_history(self):
        self.launcher.prepare("github:example/qibocamp")
        history = self.history()
        self.launcher.run_nix = Mock(side_effect=launcher.Cancelled())
        with self.assertRaises(launcher.Cancelled):
            self.launcher.prepare("github:example/other")
        self.assertEqual(self.history(), history)

    def test_default_launch_does_not_invoke_nix(self):
        self.launcher.prepare("github:example/qibocamp")
        self.launcher.run_nix = Mock(side_effect=AssertionError("Must not invoke Nix"))
        self.dialog.show.return_value = "Launch last prepared build"
        self.assertEqual(self.launcher.menu(), self.program)
        self.launcher.run_nix.assert_not_called()
        arguments = self.dialog.show.call_args.args
        index = arguments.index("Launch last prepared build")
        self.assertEqual(arguments[index - 1], "TRUE")

    def test_first_run_omits_unavailable_history_actions(self):
        self.dialog.show.return_value = "Build and launch flake reference"
        self.dialog.entry.return_value = "github:example/qibocamp"
        self.launcher.menu()
        arguments = self.dialog.show.call_args.args
        self.assertNotIn("Launch last prepared build", arguments)
        self.assertNotIn("Rebuild and launch last source", arguments)
        self.assertNotIn("Build and launch last resolved Git commit", arguments)
        index = arguments.index("Build and launch local checkout")
        self.assertEqual(arguments[index - 1], "TRUE")

    def test_missing_build_requires_explicit_rebuild_consent(self):
        self.launcher.prepare("github:example/qibocamp")
        self.program.unlink()
        self.dialog.show.side_effect = launcher.Cancelled()
        self.launcher.prepare = Mock()
        with self.assertRaises(launcher.Cancelled):
            self.launcher.last_build(self.history())
        self.launcher.prepare.assert_not_called()
        self.dialog.show.side_effect = None
        self.launcher.last_build(self.history())
        self.launcher.prepare.assert_called_once_with(self.history()["source"])

    def test_commit_replay_keeps_moving_source_and_skips_refresh(self):
        self.launcher.prepare("github:example/qibocamp?ref=main")
        source = self.history()["source"]
        self.dialog.show.return_value = "Build and launch last resolved Git commit"
        self.launcher.menu()
        self.assertEqual(self.history()["source"], source)
        self.assertFalse(self.calls[-2][1])

    def test_repository_configuration_and_relative_branch(self):
        self.dialog.show.side_effect = [
            "Set repository shortcut", "Build and launch repository branch/tag"
        ]
        self.dialog.entry.side_effect = ["github:example/qibocamp", "feature/test"]
        self.launcher.menu()
        self.assertEqual(
            launcher.read_json(self.launcher.repository_file),
            {"repository": "github:example/qibocamp"},
        )
        self.assertEqual(self.calls[0][0][-1], "github:example/qibocamp?ref=feature%2Ftest")

    def test_cancelling_revision_does_not_save_repository(self):
        self.dialog.show.return_value = "Build and launch repository branch/tag"
        self.dialog.entry.side_effect = ["github:example/qibocamp", launcher.Cancelled()]
        with self.assertRaises(launcher.Cancelled):
            self.launcher.menu()
        self.assertFalse(self.launcher.repository_file.exists())
        self.assertEqual(self.calls, [])

    def test_local_directory_is_explicit_path_with_encoded_characters(self):
        directory = self.directory / "a checkout #1"
        directory.mkdir()
        (directory / "flake.nix").touch()
        self.dialog.show.side_effect = [
            "Build and launch local checkout", str(directory)
        ]
        self.launcher.menu()
        self.assertEqual(
            self.calls[0][0][-1],
            "path:" + str(directory).replace(" ", "%20").replace("#", "%23"),
        )

    def test_nix_commands_enforce_locks_and_reject_flake_configuration(self):
        del self.launcher.run_nix
        process = Mock()
        process.poll.return_value = 0
        process.wait.return_value = 0
        process.__enter__ = Mock(return_value=process)
        process.__exit__ = Mock(return_value=None)

        def popen(command, **kwargs):
            self.command = command
            self.assertEqual(kwargs["stdin"], subprocess.DEVNULL)
            self.assertTrue(kwargs["start_new_session"])
            kwargs["stdout"].write("{}")
            return process

        with patch.object(launcher.subprocess, "Popen", side_effect=popen):
            self.launcher.run_nix(
                ["flake", "metadata", "--json", "github:example/qibocamp"],
                Mock(poll=Mock(return_value=None)), refresh=True,
            )
        self.assertEqual(self.command[:4], ["nix", "--option", "accept-flake-config", "false"])
        self.assertIn("--no-update-lock-file", self.command)
        self.assertNotIn("--no-write-lock-file", self.command)
        self.assertIn("--refresh", self.command)

    def test_cancelling_progress_terminates_preparation(self):
        del self.launcher.run_nix
        process = Mock()
        process.poll.return_value = None
        process.__enter__ = Mock(return_value=process)
        process.__exit__ = Mock(return_value=None)
        progress = Mock(poll=Mock(return_value=1), returncode=1)
        with patch.object(launcher.subprocess, "Popen", return_value=process):
            with patch.object(launcher, "terminate") as terminate:
                with self.assertRaises(launcher.Cancelled):
                    self.launcher.run_nix(["build"], progress)
                terminate.assert_called_once_with(process)

    def test_cancellation_tolerates_process_exiting_before_signal(self):
        process = Mock(pid=123)
        with patch.object(launcher.os, "killpg", side_effect=ProcessLookupError):
            launcher.terminate(process)
        process.wait.assert_called_once_with()


class ReferenceTests(unittest.TestCase):
    def test_select_package_and_reject_app_or_option_injection(self):
        self.assertEqual(
            launcher.split_reference("github:example/qibocamp#default"),
            ("github:example/qibocamp", "default"),
        )
        for value in ["", "--help", "github:x/y#apps.x86_64-linux.default", "github:x/y#foo^*"]:
            with self.subTest(value=value), self.assertRaises(launcher.LauncherError):
                launcher.split_reference(value)

    def test_git_url_preserves_subdirectory_and_encodes_revision(self):
        self.assertEqual(
            launcher.repository_reference("git+ssh://git@example.com/repo?dir=app", "feature/ui"),
            "git+ssh://git@example.com/repo?dir=app&ref=feature%2Fui",
        )
        self.assertEqual(
            launcher.repository_reference("github:example/qibocamp", COMMIT, commit=True),
            f"github:example/qibocamp?rev={COMMIT}",
        )
        for value in ["main", "abc", "a" * 39, "g" * 40]:
            with self.subTest(value=value), self.assertRaises(launcher.LauncherError):
                launcher.repository_reference("github:example/qibocamp", value, commit=True)

    def test_repository_shortcut_rejects_embedded_revision_or_output(self):
        for value in [
            "github:example/qibocamp/main", "github:example/qibocamp#default",
            "git+https://example.com/repo?ref=main", "https://example.com/repo",
        ]:
            with self.subTest(value=value), self.assertRaises(launcher.LauncherError):
                launcher.repository_reference(value)


if __name__ == "__main__":
    unittest.main()
