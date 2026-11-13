set -euo pipefail
inbox="$HOME/.local/share/private-debs"
cp package.deb "$inbox/incoming.deb"
cp wrong-architecture.deb "$inbox/rejected.deb"
"$1" &
watcher_pid=$!
cleanup() {
  kill "$watcher_pid"
  wait "$watcher_pid" || [[ $? == 143 ]]
}
trap cleanup EXIT
finished=false
for ((attempt = 0; attempt < 25; attempt++)); do
  kill -0 "$watcher_pid"
  if [[ ! -e "$inbox/incoming.deb" && ! -e "$inbox/rejected.deb" ]]; then
    finished=true
    break
  fi
  sleep 1
done
[[ "$finished" == true ]]
find "$inbox/failed" -name '*.deb' | grep .
test "$(stat -c %a "$inbox")" = 700
test "$(stat -c %a "$inbox/installed")" = 700
test "$(stat -c %a "$inbox/failed")" = 700
test "$(stat -c %a "$inbox/watcher.log")" = 600
test -z "$(find "$inbox" -type f -perm /077 -print)"
list-local-debs --json | jq -e 'length == 1 and .[0].source_deb == "incoming.deb"'
uninstall-local-deb local-deb-fixture
