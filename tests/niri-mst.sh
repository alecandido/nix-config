set -euo pipefail

helper=$1
mkdir bin
export PATH="$PWD/bin:$PATH"
export calls="$PWD/calls" outputs="$PWD/outputs"
export fail_query=0 fail_mode=0 fail_sleep=0

cat > bin/niri <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$*" == "msg --json outputs" ]]; then
  [[ "$fail_query" == 0 ]] || exit 1
  cat "$outputs"
else
  printf '%s\n' "$*" >> "$calls"
  if [[ "$*" == *59.997 && "$fail_mode" == 1 ]]; then
    exit 1
  fi
fi
EOF
cat > bin/sleep <<'EOF'
#!/usr/bin/env bash
[[ "$fail_sleep" == 0 ]]
EOF
chmod +x bin/niri bin/sleep
sed -i "1c#!$TEST_SHELL" bin/niri bin/sleep

jq -n '{
  "DP-2": {
    make: "Dell Inc.", model: "DELL U3225QE", serial: "9WJ0834",
    current_mode: 0,
    modes: [{width: 3840, height: 2160, refresh_rate: 120000}]
  },
  "DP-4": {
    make: "Dell Inc.", model: "DELL U2722D", serial: "JQKD093",
    current_mode: 0
  }
}' > "$outputs"
cp "$outputs" both.json

run_helper() {
  : > "$calls"
  bash -euo pipefail "$helper" \
    "Dell Inc. DELL U3225QE 9WJ0834" \
    "Dell Inc. DELL U2722D JQKD093"
}

run_helper
cat > expected <<'EOF'
msg output Dell Inc. DELL U3225QE 9WJ0834 mode 3840x2160@59.997
msg output Dell Inc. DELL U3225QE 9WJ0834 mode 3840x2160@120.000
EOF
diff -u expected "$calls"

jq 'del(."DP-4")' both.json > "$outputs"
run_helper
test ! -s "$calls"

jq '."DP-2".modes[0].refresh_rate = 59997' both.json > "$outputs"
run_helper
test ! -s "$calls"
cp both.json "$outputs"

export fail_query=1
if run_helper; then exit 1; fi
test ! -s "$calls"
export fail_query=0 fail_mode=1
if run_helper; then exit 1; fi
test "$(wc -l < "$calls")" -eq 1
export fail_mode=0 fail_sleep=1
if run_helper; then exit 1; fi
diff -u expected "$calls"
