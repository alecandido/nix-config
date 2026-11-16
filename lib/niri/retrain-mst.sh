primary=$1
secondary=$2
outputs=$(niri msg --json outputs)

applicable=$(jq --arg primary "$primary" --arg secondary "$secondary" '
  def identity: "\(.make) \(.model) \(.serial)";
  any(.[]; identity == $primary and .current_mode != null
    and (.modes[.current_mode] | .width == 3840 and .height == 2160 and .refresh_rate == 120000))
  and any(.[]; identity == $secondary and .current_mode != null)
' <<< "$outputs")
if [[ "$applicable" != true ]]; then
  echo "Skipping MST startup recovery: the configured dual-monitor 4K/120 Hz setup is not active."
  exit 0
fi

echo "Retraining the MST display chain through 4K/60 Hz, then restoring 4K/120 Hz."
niri msg output "$primary" mode 3840x2160@59.997
trap 'niri msg output "$primary" mode 3840x2160@120.000' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
sleep 2
