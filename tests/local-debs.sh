set -euo pipefail
umask 077
mkdir -p payload/DEBIAN payload/usr/bin payload/usr/lib payload/usr/share/applications payload/usr/share/pixmaps
mkdir -p payload/opt/fixture/bin
printf 'not an icon\n' > payload/opt/fixture/bin/fixture-icon
chmod 755 payload/DEBIAN
cat > payload/DEBIAN/control <<EOF
Package: local-deb-fixture
Version: 1.0
Architecture: all
Maintainer: Fixture <fixture@example.invalid>
Description: Synthetic runtime-only test package
EOF
cat > executable.c <<'EOF'
#include <string.h>
#include <unistd.h>
int main(int argc, char **argv) {
  if (argc > 1 && strcmp(argv[1], "--hold") == 0)
    for (;;) pause();
  return 0;
}
EOF
cc executable.c -o payload/usr/bin/fixture-run
cc -shared -fPIC executable.c -o payload/usr/lib/libfixture.so.1
cat > payload/usr/bin/fixture-script <<'EOF'
#!/bin/bash
arguments=("$@")
printf '%s\n' "${arguments[@]}"
EOF
chmod 700 payload/usr/bin/fixture-script
cat > payload/usr/lib/fixture-sidecar <<'EOF'
#!/usr/bin/env -S bash -eu
arguments=("$@")
printf '%s\n' "${arguments[@]}"
EOF
chmod 700 payload/usr/lib/fixture-sidecar
cat > bundle.js <<'EOF'
const paths = process.env.LD_LIBRARY_PATH?.split(":") || [];
if (!paths.some(path => path.endsWith("/usr/lib")) || paths.includes("")) {
  throw new Error("Bundled executable did not receive its runtime library pool");
}
if (process.env.EXPECT_LIBRARY && !paths.includes(process.env.EXPECT_LIBRARY)) {
  throw new Error("Bundled executable lost an inherited library search path");
}
console.log(process.argv.slice(2).join("|"));
EOF
bun build --compile --outfile payload/usr/lib/fixture-bundle bundle.js
printf '<svg/>\n' > payload/usr/share/pixmaps/fixture-icon.svg
cat > payload/usr/share/applications/fixture.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Runtime fixture
Exec=/usr/bin/fixture-run --flag %U
TryExec=fixture-run
Icon=fixture-icon
DBusActivatable=true
EOF
dpkg-deb --build payload package.deb
install-local-deb package.deb
registry="$HOME/.local/opt/.registry.json"
desktop="$HOME/.local/share/applications/local-deb-fixture-fixture.desktop"
jq -e 'length == 1 and .[0].version == "1.0" and (.[0].tauri_mode | not) and
  (.[0].binaries | length == 2) and .[0].source_deb == "package.deb"' "$registry"
test "$(stat -c %a "$registry")" = 600
test "$(stat -c %a "$HOME/.local/opt/local-deb-fixture")" = 700
test "$(stat -c %a "$desktop")" = 600
test "$(stat -c %a "$HOME/.local/bin/fixture-run")" = 700
grep -F "Exec=\"$HOME/.local/bin/fixture-run\" --flag %U" "$desktop"
grep -F "Icon=$HOME/.local/opt/local-deb-fixture/usr/share/pixmaps/fixture-icon.svg" "$desktop"
grep -Fx 'DBusActivatable=false' "$desktop"
! grep -q GDK_BACKEND "$HOME/.local/bin/fixture-run"
"$HOME/.local/bin/fixture-run"
test "$("$HOME/.local/bin/fixture-script" 'argument with spaces')" = 'argument with spaces'
# Sidecars are launched directly by applications, not through generated wrappers.
test "$("$HOME/.local/opt/local-deb-fixture/usr/bin/fixture-script" 'direct argument')" = 'direct argument'
test "$("$HOME/.local/opt/local-deb-fixture/usr/lib/fixture-sidecar" 'sidecar argument')" = 'sidecar argument'
test "$("$HOME/.local/opt/local-deb-fixture/usr/lib/fixture-bundle" 'bundle argument' --flag)" = 'bundle argument|--flag'
# Preserve inherited library search paths without introducing empty entries.
test "$(EXPECT_LIBRARY=/existing LD_LIBRARY_PATH=/existing "$HOME/.local/opt/local-deb-fixture/usr/lib/fixture-bundle" 'inherited argument')" = 'inherited argument'
patchelf --print-rpath "$HOME/.local/opt/local-deb-fixture/usr/bin/fixture-run" |
  grep -F "$HOME/.local/opt/local-deb-fixture/usr/lib"
patchelf --print-rpath "$HOME/.local/opt/local-deb-fixture/usr/lib/libfixture.so.1" |
  grep -F "$HOME/.local/opt/local-deb-fixture/usr/lib"
test -z "$(find "$HOME/.local/opt/local-deb-fixture" -type d ! -perm 700 -print)"
test -z "$(find "$HOME/.local/opt/local-deb-fixture" -type f -perm /077 -print)"
list-local-debs | grep -E 'local-deb-fixture +1.0 +standard'
list-local-debs --json | jq -e 'length == 1'

# Running native applications must survive rejected upgrades and uninstalls.
holding_pid=
cleanup_running_fixture() {
  if [[ -n "$holding_pid" ]]; then
    kill "$holding_pid"
    wait "$holding_pid" || [[ $? == 143 ]]
    holding_pid=
  fi
}
trap cleanup_running_fixture EXIT
"$HOME/.local/bin/fixture-run" --hold &
holding_pid=$!
for ((attempt = 0; attempt < 50; attempt++)); do
  if [[ "$(readlink "/proc/$holding_pid/exe")" == "$HOME/.local/opt/local-deb-fixture/usr/bin/fixture-run" ]]; then
    break
  fi
  sleep 0.1
done
[[ "$(readlink "/proc/$holding_pid/exe")" == "$HOME/.local/opt/local-deb-fixture/usr/bin/fixture-run" ]]
if install-local-deb package.deb > rejected.log 2>&1; then
  exit 1
fi
grep -F "still in use by PID $holding_pid" rejected.log
if uninstall-local-deb local-deb-fixture > rejected.log 2>&1; then
  exit 1
fi
grep -F "still in use by PID $holding_pid" rejected.log
jq -e 'length == 1 and .[0].version == "1.0"' "$registry"
test -x "$HOME/.local/bin/fixture-run"
cleanup_running_fixture

# Public interpreters can retain a deleted working directory in the package.
working="$HOME/.local/opt/local-deb-fixture/working"
mkdir "$working"
(cd "$working"; exec sleep 60) &
holding_pid=$!
for ((attempt = 0; attempt < 50; attempt++)); do
  if [[ "$(readlink "/proc/$holding_pid/cwd")" == "$working" ]]; then
    break
  fi
  sleep 0.1
done
[[ "$(readlink "/proc/$holding_pid/cwd")" == "$working" ]]
rmdir "$working"
if uninstall-local-deb local-deb-fixture > rejected.log 2>&1; then
  exit 1
fi
grep -F "still in use by PID $holding_pid" rejected.log
cleanup_running_fixture
trap - EXIT

# Upgrades remove obsolete wrappers and desktop entries.
rm payload/usr/bin/fixture-script payload/usr/share/applications/fixture.desktop
sed -i 's/Version: 1.0/Version: 2.0/' payload/DEBIAN/control
dpkg-deb --build payload upgrade.deb
install-local-deb --tauri upgrade.deb
test ! -e "$HOME/.local/bin/fixture-script"
test ! -e "$desktop"
grep -Fx 'export GDK_BACKEND="wayland"' "$HOME/.local/bin/fixture-run"
jq -e 'length == 1 and .[0].version == "2.0" and .[0].tauri_mode' "$registry"
install-local-deb --no-tauri upgrade.deb
! grep -q GDK_BACKEND "$HOME/.local/bin/fixture-run"

# Automatic WebKit detection and the explicit opt-out apply per executable.
patchelf --add-needed libwebkit2gtk-fixture.so payload/usr/bin/fixture-run
dpkg-deb --build payload webkit.deb
install-local-deb webkit.deb > automatic.log 2>&1
grep -Fx 'export GDK_BACKEND="wayland"' "$HOME/.local/bin/fixture-run"
grep -F libwebkit2gtk-fixture.so automatic.log
install-local-deb --no-tauri webkit.deb > opt-out.log 2>&1
! grep -q GDK_BACKEND "$HOME/.local/bin/fixture-run"

# Architecture rejection preserves the installed version.
sed -i 's/Architecture: all/Architecture: invalid/' payload/DEBIAN/control
dpkg-deb --build payload wrong-architecture.deb
if install-local-deb wrong-architecture.deb > rejected.log 2>&1; then
  exit 1
fi
grep -F incompatible rejected.log
jq -e 'length == 1 and .[0].version == "2.0"' "$registry"

# A wrapper belonging to another user application must not be replaced.
sed -i 's/Architecture: invalid/Architecture: all/; s/Package: local-deb-fixture/Package: other-fixture/' payload/DEBIAN/control
dpkg-deb --build payload collision.deb
if install-local-deb collision.deb > rejected.log 2>&1; then
  exit 1
fi
grep -F 'wrapper collision' rejected.log

# Escaping archive links are rejected before extraction.
ln -s "$HOME/outside" payload/escape
dpkg-deb --build payload escaping.deb
if install-local-deb escaping.deb > rejected.log 2>&1; then
  exit 1
fi
grep -F 'escaping link' rejected.log
test ! -e "$HOME/outside"

# Reconciliation also removes launchers whose package tree was manually removed.
rm -r "$HOME/.local/opt/local-deb-fixture"
list-local-debs --json | jq -e 'length == 0'
test ! -e "$HOME/.local/bin/fixture-run"
install-local-deb package.deb
# Missing-manifest recovery uses explicit ownership markers.
printf '[]\n' > "$registry"
uninstall-local-deb local-deb-fixture
test ! -e "$HOME/.local/bin/fixture-run"
test ! -e "$desktop"
test ! -e "$HOME/.local/opt/local-deb-fixture"
if uninstall-local-deb ../fixtures > rejected.log 2>&1; then
  exit 1
fi
test -d "$HOME/.local/opt/fixtures"
