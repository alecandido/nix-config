import fcntl
import itertools
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path


class Niri:
    def query(self, command):
        result = subprocess.run(
            ["niri", "msg", "--json", command],
            check=True,
            capture_output=True,
            text=True,
        )
        return json.loads(result.stdout)

    def action(self, *arguments):
        subprocess.run(
            ["niri", "msg", "action", *map(str, arguments)],
            check=True,
            capture_output=True,
            text=True,
        )


def wait_for(niri, predicate, description, timeout=10):
    deadline = time.monotonic() + timeout
    while True:
        windows = niri.query("windows")
        if predicate(windows):
            return windows
        if time.monotonic() >= deadline:
            raise RuntimeError(f"Timed out waiting for {description}")
        time.sleep(0.05)


def focus(niri, window_id):
    niri.action("focus-window", "--id", window_id)
    wait_for(
        niri,
        lambda windows: any(w["id"] == window_id and w["is_focused"] for w in windows),
        f"focus on window {window_id}",
    )


def column_members(windows, window_id):
    window = next(w for w in windows if w["id"] == window_id)
    position = window["layout"]["pos_in_scrolling_layout"]
    if window["is_floating"] or position is None:
        return []
    return [
        w
        for w in windows
        if not w["is_floating"]
        and w["workspace_id"] == window["workspace_id"]
        and w["layout"]["pos_in_scrolling_layout"][0] == position[0]
    ]


def restore(layout, niri, launch, timeout=60):
    workspaces = {w["name"]: w["id"] for w in niri.query("workspaces")}
    applications = {}
    for workspace in layout["workspaces"]:
        if workspace["name"] not in workspaces:
            raise RuntimeError(f"Missing Niri workspace: {workspace['name']}")
        for column in workspace["columns"]:
            for app in column["windows"]:
                desktop = app["desktop"]
                if desktop in applications:
                    raise ValueError(f"Duplicate application in layout: {desktop}")
                applications[desktop] = re.compile(app["app_id"])
    if layout["focus"] not in applications:
        raise ValueError("The focused application is not in the layout")
    for workspace in layout["workspaces"]:
        desktops = {
            app["desktop"]
            for column in workspace["columns"]
            for app in column["windows"]
        }
        if workspace["active"] not in desktops:
            raise ValueError(f"Invalid active application for {workspace['name']}")

    selected = {}

    def find_windows(windows):
        for desktop, pattern in applications.items():
            if desktop not in selected:
                used = set(selected.values())
                matches = [
                    w["id"]
                    for w in windows
                    if w["id"] not in used and pattern.fullmatch(w["app_id"] or "")
                ]
                if matches:
                    selected[desktop] = min(matches)
        return len(selected) == len(applications)

    find_windows(niri.query("windows"))
    for desktop in applications:
        if desktop not in selected:
            launch(desktop)
    wait_for(
        niri,
        find_windows,
        "application windows: " + ", ".join(applications),
        timeout,
    )

    # Separate the selected windows before assembling columns; leave other windows alone.
    for workspace in layout["workspaces"]:
        workspace_id = workspaces[workspace["name"]]
        for column in workspace["columns"]:
            for app in column["windows"]:
                window_id = selected[app["desktop"]]
                niri.action("move-window-to-tiling", "--id", window_id)
                niri.action(
                    "move-window-to-workspace",
                    "--window-id",
                    window_id,
                    "--focus",
                    "false",
                    workspace["name"],
                )
                windows = wait_for(
                    niri,
                    lambda windows, window_id=window_id, workspace_id=workspace_id: any(
                        w["id"] == window_id
                        and not w["is_floating"]
                        and w["workspace_id"] == workspace_id
                        for w in windows
                    ),
                    f"window {window_id} on {workspace['name']}",
                )
                if len(column_members(windows, window_id)) > 1:
                    focus(niri, window_id)
                    niri.action("consume-or-expel-window-right")
                    wait_for(
                        niri,
                        lambda windows, window_id=window_id: (
                            len(column_members(windows, window_id)) == 1
                        ),
                        f"window {window_id} in a separate column",
                    )

    for workspace in layout["workspaces"]:
        for index, column in enumerate(workspace["columns"], start=1):
            ids = [selected[app["desktop"]] for app in column["windows"]]
            anchor = ids[0]
            focus(niri, anchor)
            niri.action("move-column-to-index", index)
            niri.action("set-column-display", "normal")
            niri.action("set-column-width", column["width"])
            for previous, window_id in itertools.pairwise(ids):
                focus(niri, window_id)
                niri.action("move-column-to-index", index + 1)
                focus(niri, previous)
                niri.action("consume-window-into-column")
                wait_for(
                    niri,
                    lambda windows, window_id=window_id, anchor=anchor: (
                        window_id in {w["id"] for w in column_members(windows, anchor)}
                    ),
                    f"window {window_id} in column {index}",
                )
            for window_id in ids:
                niri.action("reset-window-height", "--id", window_id)
        focus(niri, selected[workspace["active"]])
    focus(niri, selected[layout["focus"]])


def main():
    with open(sys.argv[1]) as source:
        layout = json.load(source)
    lock_path = Path(os.environ["XDG_RUNTIME_DIR"]) / "niri-restore-desktop.lock"
    with lock_path.open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError("Desktop restoration is already running") from None
        restore(
            layout,
            Niri(),
            lambda desktop: subprocess.run(
                ["gtk-launch", f"{desktop}.desktop"], check=True
            ),
        )
    print("Desktop layout restored.")


if __name__ == "__main__":
    try:
        main()
    except (
        OSError,
        ValueError,
        KeyError,
        RuntimeError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"niri-restore-desktop: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        sys.exit(1)
