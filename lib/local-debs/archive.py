import posixpath
import sys
import tarfile


links = set()
members = []
with tarfile.open(fileobj=sys.stdin.buffer, mode="r|") as archive:
    for member in archive:
        name = posixpath.normpath(member.name)
        if member.name.startswith("/") or name == ".." or name.startswith("../"):
            raise ValueError("Debian archive contains an escaping path")
        if not (member.isfile() or member.isdir() or member.issym() or member.islnk()):
            raise ValueError("Debian archive contains a special file")
        if member.issym() or member.islnk():
            base = posixpath.dirname(name) if member.issym() else ""
            destination = posixpath.normpath(posixpath.join(base, member.linkname))
            if destination.startswith("/") or destination == ".." or destination.startswith("../"):
                raise ValueError("Debian archive contains an escaping link")
            links.add(name)
            if member.islnk():
                members.append(destination)
        members.append(name)

# Reject archive writes through links, regardless of archive member ordering.
for name in members:
    parent = posixpath.dirname(name)
    while parent not in ("", "."):
        if parent in links:
            raise ValueError("Debian archive traverses a link")
        parent = posixpath.dirname(parent)
