mode=auto
case "${1:-}" in
  --tauri) mode=tauri; shift ;;
  --no-tauri) mode=standard; shift ;;
esac
[[ $# == 1 && "$1" != --* ]] ||
  die "usage: install-local-deb [--tauri|--no-tauri] <path-to-deb>"
source_deb="$(realpath -e -- "$1")"
[[ -f "$source_deb" ]] || die "not a regular Debian package"

work="$(mktemp -d "$root/.install.XXXXXXXX")"
export TMPDIR="$work"
export PYTHONDONTWRITEBYTECODE=1
package=
committing=false
cleanup() {
  local status=$?
  trap - EXIT
  if [[ "$committing" == true && $status != 0 ]]; then
    remove_package "$package"
  fi
  rm -rf -- "$work"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
cp -- "$source_deb" "$work/source.deb"
chmod 600 "$work/source.deb"
package="$(dpkg-deb -f "$work/source.deb" Package)"
version="$(dpkg-deb -f "$work/source.deb" Version)"
architecture="$(dpkg-deb -f "$work/source.deb" Architecture)"
description="$(dpkg-deb -f "$work/source.deb" Description)"
valid_package "$package" || die "invalid Debian package name"
case "$(uname -m):$architecture" in
  x86_64:amd64|aarch64:arm64|i?86:i386|armv7l:armhf|ppc64le:ppc64el|riscv64:riscv64|*:all) ;;
  *) die "architecture $architecture is incompatible with $(uname -m)" ;;
esac

target="$root/$package"
mkdir -m 700 "$work/tree"
dpkg-deb --fsys-tarfile "$work/source.deb" | python3 "$archive_helper"
dpkg-deb -x "$work/source.deb" "$work/tree"
# Reject escaping links before traversing or modifying the extracted tree.
while IFS= read -r -d '' path; do
  resolved="$(realpath -m -- "$path")"
  [[ "$resolved" == "$work/tree/"* ]] || die "package contains an escaping symlink"
done < <(find "$work/tree" -type l -print0)
find "$work/tree" -type d -exec chmod 700 {} +
find "$work/tree" -type f -perm /111 -exec chmod 700 {} +
find "$work/tree" -type f ! -perm /111 -exec chmod 600 {} +

declare -A binaries=()
while IFS= read -r -d '' path; do
  [[ -f "$path" && -x "$path" ]] || continue
  name="${path##*/}"
  [[ "$name" =~ ^[a-zA-Z0-9._+-]+$ && "$name" != "." && "$name" != ".." ]] ||
    die "unsupported executable filename: $name"
  relative="${path#"$work/tree/"}"
  [[ ! -v "binaries[$name]" || "${binaries[$name]}" == "$relative" ]] ||
    die "duplicate executable name: $name"
  binaries["$name"]="$relative"
  if [[ -e "$bin_dir/$name" || -L "$bin_dir/$name" ]]; then
    owned_wrapper "$bin_dir/$name" "$package" || die "wrapper collision: $name"
  fi
done < <(find "$work/tree" \( -type f -o -type l \) \
  \( -path "$work/tree/usr/bin/*" -o -path "$work/tree/usr/local/bin/*" -o -path "$work/tree/opt/*/bin/*" \) -print0)

# Add bundled library directories (including multiarch and opt layouts).
rpath="$runtime_rpath:$target/usr/lib"
while IFS= read -r -d '' directory; do
  [[ "$directory" != *:* && "$directory" != *$'\n'* ]] || die "unsupported library directory"
  rpath="$rpath:$target/${directory#"$work/tree/"}"
done < <(find "$work/tree" \( -type f -o -type l \) -name '*.so*' -printf '%h\0' | sort -zu)
elf_files=()
while IFS= read -r -d '' path; do
  [[ -f "$path" ]] || continue
  [[ "$(head -c 4 -- "$path")" == $'\177ELF' ]] || continue
  elf_files+=("$path")
  if patchelf --print-interpreter "$path" > /dev/null 2>&1; then
    patchelf --set-interpreter "$dynamic_linker" --set-rpath "$rpath" "$path"
  elif patchelf --print-needed "$path" > /dev/null 2>&1; then
    patchelf --set-rpath "$rpath" "$path"
  else
    printf 'Warning: static or non-dynamic ELF left unchanged: %s\n' "${path#"$work/tree/"}" >&2
  fi
done < <(find "$work/tree" \( -type f -o -type l \) \( -perm /111 -o -name '*.so*' \) -print0)

mapping='{}'
any_tauri=false
if [[ "$mode" == tauri ]]; then
  any_tauri=true
fi
mkdir -m 700 "$work/wrappers" "$work/desktops"
for name in "${!binaries[@]}"; do
  path="$work/tree/${binaries[$name]}"
  tauri=false
  if [[ "$mode" == tauri ]] ||
    { [[ "$mode" == auto && "$(head -c 4 -- "$path")" == $'\177ELF' ]] &&
      patchelf --print-needed "$path" | grep '^libwebkit2gtk' > /dev/null; }; then
    tauri=true
    any_tauri=true
  fi
  {
    printf '#!%s\n# local-deb-owner: %s\n' "$wrapper_shell" "$package"
    if [[ "$tauri" == true ]]; then
      printf 'export GDK_BACKEND="wayland"\nexport WEBKIT_DISABLE_DMABUF_RENDERER="1"\n'
      printf 'export GIO_MODULE_DIR=%q\n' "$gio_modules"
      printf "export XDG_DATA_DIRS=%q:\"\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}\"\n" "$schema_dirs"
    fi
    printf 'exec %q "$@"\n' "$target/${binaries[$name]}"
  } > "$work/wrappers/$name"
  chmod 700 "$work/wrappers/$name"
  mapping="$(jq --arg name "$name" --arg path "$bin_dir/$name" '. + {($name): $path}' <<< "$mapping")"
done
python3 "$desktop_helper" "$work/tree" "$target" "$package" "$work/desktops" "$mapping"
while IFS= read -r -d '' path; do
  destination="$desktop_dir/${path##*/}"
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -L "$destination" ]] || ! grep -Fxq "X-Local-Deb-Owner=$package" "$destination"; then
      die "desktop collision: $destination"
    fi
  fi
done < <(find "$work/desktops" -type f -print0)

# Validate everything before removing an existing version.
remove_package "$package"
committing=true
mv -T -- "$work/tree" "$target"
wrapper_paths='[]'
desktop_paths='[]'
for name in "${!binaries[@]}"; do
  mv -T -- "$work/wrappers/$name" "$bin_dir/$name"
  wrapper_paths="$(jq --arg path "$bin_dir/$name" '. + [$path]' <<< "$wrapper_paths")"
done
while IFS= read -r -d '' path; do
  destination="$desktop_dir/${path##*/}"
  mv -T -- "$path" "$destination"
  desktop_paths="$(jq --arg path "$destination" '. + [$path]' <<< "$desktop_paths")"
done < <(find "$work/desktops" -type f -print0)

# Resolve DT_NEEDED without ldd: ldd can execute code from an untrusted ELF.
unresolved='[]'
for path in "${elf_files[@]}"; do
  path="$target/${path#"$work/tree/"}"
  if ! needed="$(patchelf --print-needed "$path" 2>/dev/null)"; then
    continue
  fi
  while IFS= read -r library; do
    [[ -n "$library" ]] || continue
    found=false
    IFS=: read -r -a search_dirs <<< "$rpath"
    search_dirs+=("${dynamic_linker%/*}")
    for directory in "${search_dirs[@]}"; do
      if [[ -e "$directory/$library" ]]; then
        found=true
        break
      fi
    done
    if [[ "$found" == false ]]; then
      unresolved="$(jq --arg library "$library" '. + [$library] | unique' <<< "$unresolved")"
    fi
  done <<< "$needed"
done
if [[ "$unresolved" != '[]' ]]; then
  printf 'Warning: unresolved shared libraries; add providers to programs.localDebInstaller.extraRuntimeLibs:\n' >&2
  jq -r '.[] | "  " + .' <<< "$unresolved" >&2
fi

archived="$(mktemp "$archive/XXXXXXXX.deb")"
mv -T -- "$work/source.deb" "$archived"
jq --arg package "$package" --arg version "$version" --arg architecture "$architecture" \
  --arg installed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg source_deb "${source_deb##*/}" --argjson tauri_mode "$any_tauri" \
  --argjson binaries "$wrapper_paths" --argjson desktop_files "$desktop_paths" \
  '. + [{package: $package, version: $version, architecture: $architecture,
    installed_at: $installed_at, tauri_mode: $tauri_mode, binaries: $binaries,
    desktop_files: $desktop_files, source_deb: $source_deb}]' "$registry" | write_registry
committing=false
printf 'Installed %s %s (%s)\n%s\n' "$package" "$version" "$architecture" "$description"
