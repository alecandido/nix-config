import json
import os
from pathlib import Path
import shlex
import sys


tree, target, package, output, mapping = sys.argv[1:]
tree, target, output = Path(tree), Path(target), Path(output)
mapping = json.loads(mapping)


def quote(value):
    # Desktop Exec syntax has an additional escaping layer, unlike shell syntax.
    value = value.replace("\\", "\\\\\\\\")
    for character in ('"', "`", "$"):
        value = value.replace(character, "\\" + character)
    return '"' + value.replace("%", "%%") + '"'


def extracted_path(value):
    path = tree / value.lstrip("/")
    if path.is_file() and path.resolve().is_relative_to(tree.resolve()):
        return str(target / path.relative_to(tree))
    return None


sources = sorted(
    set((tree / "usr/share/applications").glob("*.desktop"))
    | set((tree / "opt").rglob("*.desktop"))
)
icons = sorted(
    set((tree / "usr/share/icons").rglob("*"))
    | set((tree / "usr/share/pixmaps").rglob("*"))
    | set((tree / "opt").rglob("*"))
)
for source in sources:
    destination = output / f"{package}-{source.name}"
    if destination.exists():
        raise ValueError(f"Duplicate desktop filename: {source.name}")
    lines = []
    for line in source.read_text().splitlines():
        if line.startswith(("Exec=", "TryExec=")):
            key, value = line.split("=", 1)
            tokens = shlex.split(value)
            if not tokens or Path(tokens[0]).name not in mapping:
                raise ValueError(f"Desktop command has no discovered wrapper: {source.name}")
            wrapper = mapping[Path(tokens[0]).name]
            if key == "TryExec":
                line = f"TryExec={wrapper}"
            else:
                # Preserve argument text and desktop field codes verbatim.
                lexer = shlex.shlex(value, posix=True)
                lexer.whitespace_split = True
                next(lexer)
                remainder = value[lexer.instream.tell():]
                line = f"Exec={quote(wrapper)} {remainder}".rstrip()
        elif line.startswith("Icon="):
            value = line.split("=", 1)[1]
            icon = extracted_path(value)
            if icon is None and "/" not in value:
                matches = [
                    path for path in icons
                    if path.is_file()
                    and path.suffix.lower() in (".png", ".svg", ".svgz", ".xpm", ".ico", ".jpg", ".jpeg")
                    and (path.name == value or path.stem == value)
                ]
                if matches:
                    icon = extracted_path(str(matches[0].relative_to(tree)))
            if icon:
                line = f"Icon={icon}"
        elif line.startswith("Path="):
            value = line.split("=", 1)[1]
            path = tree / value.lstrip("/")
            if path.is_dir():
                line = f"Path={target / path.relative_to(tree)}"
        elif line.startswith("X-Local-Deb-Owner="):
            continue
        elif line.startswith("DBusActivatable="):
            line = "DBusActivatable=false"
        lines.append(line)
        if line == "[Desktop Entry]":
            lines.append(f"X-Local-Deb-Owner={package}")
    destination.write_text("\n".join(lines) + "\n")
    os.chmod(destination, 0o600)
