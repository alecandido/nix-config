import copy
import importlib.util
import json
import sys
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("restore_layout", sys.argv.pop(1))
restore_layout = importlib.util.module_from_spec(spec)
spec.loader.exec_module(restore_layout)
with open(sys.argv.pop(1)) as source:
    LAYOUT = json.load(source)

APPS = {
    "com.mitchellh.ghostty": "com.mitchellh.ghostty",
    "firefox": "firefox",
    "ms-teams": "ms-teams",
    "org.telegram.desktop": "org.telegram.desktop",
    "spotify": "Spotify",
    "thunderbird": "thunderbird",
}


class FakeNiri:
    def __init__(self):
        self.workspaces = {"1-code": 1, "2-web": 2, "4-comms": 4, "5-aux": 5}
        self.columns = {workspace_id: [] for workspace_id in self.workspaces.values()}
        self.apps = {}
        self.focused = None
        self.actions = []
        self.launched = []
        self.heights = set()

    def launch(self, desktop):
        self.launched.append(desktop)
        self.add(APPS[desktop], 5)

    def add(self, app_id, workspace_id):
        window_id = len(self.apps) + 1
        self.apps[window_id] = app_id
        self.columns[workspace_id].append([window_id])
        return window_id

    def locate(self, window_id):
        for workspace_id, columns in self.columns.items():
            for index, column in enumerate(columns):
                if window_id in column:
                    return workspace_id, index, column
        raise AssertionError(f"Unknown window: {window_id}")

    def query(self, command):
        if command == "workspaces":
            return [{"name": name, "id": wid} for name, wid in self.workspaces.items()]
        assert command == "windows"
        windows = []
        for workspace_id, columns in self.columns.items():
            for x, column in enumerate(columns, start=1):
                for y, window_id in enumerate(column, start=1):
                    windows.append(
                        {
                            "id": window_id,
                            "app_id": self.apps[window_id],
                            "workspace_id": workspace_id,
                            "is_focused": window_id == self.focused,
                            "is_floating": False,
                            "layout": {"pos_in_scrolling_layout": [x, y]},
                        }
                    )
        return windows

    def action(self, action, *arguments):
        self.actions.append((action, *arguments))
        if action == "focus-window":
            self.focused = arguments[1]
        elif action == "move-window-to-workspace":
            window_id = arguments[1]
            destination = self.workspaces[arguments[-1]]
            workspace_id, index, column = self.locate(window_id)
            if workspace_id != destination:
                column.remove(window_id)
                if not column:
                    self.columns[workspace_id].pop(index)
                self.columns[destination].append([window_id])
        elif action == "consume-or-expel-window-right":
            workspace_id, index, column = self.locate(self.focused)
            assert len(column) > 1
            column.remove(self.focused)
            self.columns[workspace_id].insert(index + 1, [self.focused])
        elif action == "move-column-to-index":
            workspace_id, index, column = self.locate(self.focused)
            self.columns[workspace_id].pop(index)
            self.columns[workspace_id].insert(arguments[0] - 1, column)
        elif action == "consume-window-into-column":
            workspace_id, index, column = self.locate(self.focused)
            adjacent = self.columns[workspace_id][index + 1]
            window_id = adjacent.pop(0)
            column.insert(column.index(self.focused) + 1, window_id)
            if not adjacent:
                self.columns[workspace_id].pop(index + 1)
        elif action == "reset-window-height":
            self.heights.add(arguments[1])
        else:
            assert action in {
                "move-window-to-tiling",
                "set-column-display",
                "set-column-width",
            }, action

    def arrangement(self, workspace):
        return [
            [self.apps[window_id] for window_id in column]
            for column in self.columns[self.workspaces[workspace]]
        ]


class LayoutTests(unittest.TestCase):
    def assert_layout(self, niri):
        self.assertEqual(niri.arrangement("1-code")[0], ["com.mitchellh.ghostty"])
        self.assertEqual(niri.arrangement("2-web")[0], ["firefox"])
        self.assertEqual(
            niri.arrangement("4-comms")[:2],
            [
                ["ms-teams", "org.telegram.desktop", "Spotify"],
                ["thunderbird"],
            ],
        )
        self.assertEqual(niri.apps[niri.focused], "com.mitchellh.ghostty")
        self.assertEqual(len(niri.heights), 6)
        self.assertEqual(
            sum(action == ("set-column-width", "100%") for action in niri.actions),
            4,
        )

    def test_launches_missing_windows_and_builds_layout(self):
        niri = FakeNiri()
        restore_layout.restore(LAYOUT, niri, niri.launch)
        self.assertEqual(set(niri.launched), set(APPS))
        self.assert_layout(niri)

    def test_reuses_windows_and_preserves_unrelated_windows_on_repeat(self):
        niri = FakeNiri()
        restore_layout.restore(LAYOUT, niri, niri.launch)
        extra = niri.add("unrelated", 4)
        # Mix an unrelated window into the saved stack before restoring again.
        niri.columns[4][-1].remove(extra)
        niri.columns[4].pop()
        niri.columns[4][0].append(extra)
        niri.launched.clear()
        niri.actions.clear()
        restore_layout.restore(LAYOUT, niri, niri.launch)
        self.assertEqual(niri.launched, [])
        self.assertEqual(len(niri.apps), 7)
        self.assertEqual(niri.locate(extra)[0], 4)
        self.assert_layout(niri)

    def test_matches_existing_teams_app_id(self):
        niri = FakeNiri()
        window_id = niri.add("chrome-teams.microsoft.com__v2_-Default", 4)
        restore_layout.restore(LAYOUT, niri, niri.launch)
        self.assertNotIn("ms-teams", niri.launched)
        self.assertEqual(niri.locate(window_id)[0], 4)
        self.assertEqual(len(niri.apps), 6)

    def test_missing_workspace_fails_before_launching(self):
        niri = FakeNiri()
        del niri.workspaces["4-comms"]
        with self.assertRaisesRegex(RuntimeError, "Missing Niri workspace: 4-comms"):
            restore_layout.restore(LAYOUT, niri, niri.launch)
        self.assertEqual(niri.launched, [])
        self.assertEqual(niri.actions, [])

    def test_spawn_timeout_does_not_partially_rearrange(self):
        niri = FakeNiri()
        with self.assertRaisesRegex(RuntimeError, "Timed out waiting"):
            restore_layout.restore(LAYOUT, niri, lambda desktop: None, timeout=0)
        self.assertEqual(niri.actions, [])

    def test_waits_for_delayed_window(self):
        niri = FakeNiri()
        query = niri.query
        pending = []

        def delayed_query(command):
            if command == "windows" and pending:
                niri.launch(pending.pop())
            return query(command)

        with patch.object(niri, "query", side_effect=delayed_query):
            restore_layout.restore(LAYOUT, niri, pending.append)
        self.assert_layout(niri)

    def test_duplicate_application_is_rejected(self):
        niri = FakeNiri()
        layout = copy.deepcopy(LAYOUT)
        layout["workspaces"].append(layout["workspaces"][0])
        with self.assertRaisesRegex(ValueError, "Duplicate application"):
            restore_layout.restore(layout, niri, niri.launch)
        self.assertEqual(niri.launched, [])


unittest.main()
