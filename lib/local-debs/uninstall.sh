[[ $# == 1 ]] || die "usage: uninstall-local-deb <package-name>"
valid_package "$1" || die "invalid package name"
remove_package "$1"
printf 'Removed %s\n' "$1"
