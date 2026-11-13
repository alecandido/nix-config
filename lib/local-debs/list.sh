[[ $# == 0 || ( $# == 1 && "$1" == "--json" ) ]] ||
  die "usage: list-local-debs [--json]"
while IFS= read -r package; do
  if [[ ! -d "$root/$package" || -L "$root/$package" ]]; then
    printf 'local-debs: reconciling missing package %s\n' "$package" >&2
    remove_package "$package"
  fi
done < <(jq -r '.[].package' "$registry")
if [[ $# == 1 ]]; then
  cat "$registry"
else
  jq -r --arg prefix "$bin_dir/" '
    [["PACKAGE", "VERSION", "MODE", "BINARIES", "INSTALLED"]] +
    (map([.package, .version, (if .tauri_mode then "tauri" else "standard" end),
      (.binaries | map(ltrimstr($prefix)) | join(", ")), .installed_at[0:10]])) |
    .[] | @tsv
  ' "$registry" | column -t -s $'\t'
fi
