{pkgs, ...}:
pkgs.runCommand "niri-mst-check" {
  nativeBuildInputs = [pkgs.jq pkgs.shellcheck];
} ''
  shellcheck -s bash ${../lib/niri/retrain-mst.sh} ${./niri-mst.sh}
  export TEST_SHELL=${pkgs.bash}/bin/bash
  bash ${./niri-mst.sh} ${../lib/niri/retrain-mst.sh}
  touch "$out"
''
