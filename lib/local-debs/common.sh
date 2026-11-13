umask 077

die() {
  printf 'local-debs: %s\n' "$*" >&2
  exit 1
}

valid_package() {
  [[ "$1" =~ ^[a-z0-9][a-z0-9+.-]+$ ]]
}

private_directory() {
  [[ ! -L "$1" && ( ! -e "$1" || ( -d "$1" && -O "$1" ) ) ]] ||
    die "unsafe directory: $1"
  mkdir -p -- "$1"
  chmod 700 -- "$1"
}

root="$HOME/.local/opt"
bin_dir="$HOME/.local/bin"
desktop_dir="$HOME/.local/share/applications"
archive="$HOME/.local/share/private-debs/installed"
registry="$root/.registry.json"
for directory in "$HOME/.local" "$HOME/.local/share"; do
  [[ ! -L "$directory" && ( ! -e "$directory" || ( -d "$directory" && -O "$directory" ) ) ]] ||
    die "unsafe directory: $directory"
done
for directory in "$root" "$bin_dir" "$desktop_dir" "${archive%/installed}" "$archive"; do
  private_directory "$directory"
done
[[ ! -L "$root/.lock" && ( ! -e "$root/.lock" || ( -f "$root/.lock" && -O "$root/.lock" ) ) ]] ||
  die "unsafe registry lock"
exec 9>"$root/.lock"
chmod 600 "$root/.lock"
flock -x 9
[[ ! -L "$registry" && ( ! -e "$registry" || ( -f "$registry" && -O "$registry" ) ) ]] ||
  die "unsafe registry"
if [[ ! -e "$registry" ]]; then
  printf '[]\n' > "$registry"
fi
chmod 600 "$registry"
jq -e '
  type == "array" and all(.[];
    (.package | type == "string" and test("^[a-z0-9][a-z0-9+.-]+$")) and
    (.version | type == "string") and
    (.architecture | type == "string") and
    (.installed_at | type == "string") and
    (.tauri_mode | type == "boolean") and
    (.binaries | type == "array" and all(.[]; type == "string")) and
    (.desktop_files | type == "array" and all(.[]; type == "string")) and
    (.source_deb | type == "string")
  ) and ([.[].package] | length == (unique | length))
' "$registry" > /dev/null || die "invalid registry; refusing to overwrite it"

write_registry() {
  local temporary
  temporary="$(mktemp "$root/.registry.XXXXXXXX")"
  cat > "$temporary"
  chmod 600 "$temporary"
  mv -T -- "$temporary" "$registry"
}

owned_wrapper() {
  [[ -f "$1" && ! -L "$1" ]] &&
    grep -Fxq -- "# local-deb-owner: $2" "$1"
}

remove_package() {
  local package="$1" path name
  valid_package "$package" || die "invalid package name"
  while IFS= read -r -d '' path; do
    name="${path##*/}"
    [[ "$path" == "$bin_dir/$name" && "$name" != "." && "$name" != ".." ]] ||
      die "unsafe wrapper path in registry"
    if [[ -e "$path" || -L "$path" ]]; then
      owned_wrapper "$path" "$package" || die "wrapper no longer belongs to package: $path"
      rm -- "$path"
    fi
  done < <(jq -j --arg package "$package" '.[] | select(.package == $package) | .binaries[] | ., "\u0000"' "$registry")
  while IFS= read -r -d '' path; do
    [[ "$path" == "$desktop_dir/$package-"*.desktop && "${path#"$desktop_dir/"}" != */* ]] ||
      die "unsafe desktop path in registry"
    if [[ -e "$path" || -L "$path" ]]; then
      if [[ -L "$path" ]] || ! grep -Fxq -- "X-Local-Deb-Owner=$package" "$path"; then
        die "desktop file no longer belongs to package: $path"
      fi
      rm -- "$path"
    fi
  done < <(jq -j --arg package "$package" '.[] | select(.package == $package) | .desktop_files[] | ., "\u0000"' "$registry")
  # Ownership markers allow recovery even if the registry entry was lost.
  while IFS= read -r -d '' path; do
    if owned_wrapper "$path" "$package"; then
      rm -- "$path"
    fi
  done < <(find "$bin_dir" -maxdepth 1 -type f -print0)
  while IFS= read -r -d '' path; do
    if grep -Fxq -- "X-Local-Deb-Owner=$package" "$path"; then
      rm -- "$path"
    fi
  done < <(find "$desktop_dir" -maxdepth 1 -type f -name "$package-*.desktop" -print0)
  [[ ! -L "$root/$package" ]] || die "unsafe package directory"
  rm -rf -- "${root:?}/${package:?}"
  jq --arg package "$package" 'map(select(.package != $package))' "$registry" | write_registry
}
