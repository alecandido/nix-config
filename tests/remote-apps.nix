{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  rose = inputs.self.nixosConfigurations.rose-oasis.config;
  ocopoli = inputs.self.nixosConfigurations.ocopoli.config;
  donaldville = inputs.self.darwinConfigurations.donaldville.config;
  home = config: config.home-manager.users.alessandro;
  rosePkgs = inputs.self.nixosConfigurations.rose-oasis.pkgs;
  ocopoliPkgs = inputs.self.nixosConfigurations.ocopoli.pkgs;
  wayland = pkgs.callPackage ../lib/remote-apps/xpra-wayland.nix {};
in
  assert lib.elem rosePkgs.xpra (home rose).home.packages;
  assert lib.elem ocopoliPkgs.xpra (home ocopoli).home.packages;
  assert lib.any (p: p.name == "xpra-wayland") (home rose).home.packages;
  assert lib.any (p: p.pname or "" == "xpra-macos") (home donaldville).home.packages;
  assert (home ocopoli).programs.ssh.settings.rose-oasis.data.user == "alessandro";
  assert (home donaldville).programs.ssh.settings.rose-oasis.data.user == "alessandro";
  assert rose.services.openssh.enable && rose.services.tailscale.enable;
  assert lib.elem rosePkgs.waypipe rose.environment.systemPackages;
  assert lib.elem ocopoliPkgs.waypipe ocopoli.environment.systemPackages;
    pkgs.runCommand "remote-apps-check" {
      nativeBuildInputs = [pkgs.xterm pkgs.weston];
    } ''
      export PATH="${lib.makeBinPath [pkgs.xpra wayland]}:$PATH"
      export HOME="$TMPDIR/home"
      export XDG_RUNTIME_DIR="$TMPDIR/runtime"
      mkdir -m 700 "$HOME" "$XDG_RUNTIME_DIR"
      unset DISPLAY WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS
      export WLR_RENDERER=pixman

      pids=()
      cleanup() {
        status=$?
        trap - EXIT
        if (( status != 0 )); then
          cat ./*.log
        fi
        for pid in "''${pids[@]}"; do
          if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            wait "$pid" || true
          fi
        done
        exit "$status"
      }
      trap cleanup EXIT

      common=(
        --daemon=no
        --systemd-run=no
        --mdns=no
        --pulseaudio=no
        --notifications=no
        --printing=no
        --webcam=no
        --dbus-launch=
        --dbus-control=no
        --exit-with-children=yes
      )
      xpra seamless :100 --backend=x11 "''${common[@]}" \
        --start-child='xterm -title remote-x11-test' > x11.log 2>&1 &
      pids+=("$!")
      xpra-wayland seamless :101 --backend=wayland "''${common[@]}" \
        --start-child=weston-terminal > wayland.log 2>&1 &
      pids+=("$!")

      for display in 100 101; do
        ready=false
        for attempt in {1..30}; do
          if ! kill -0 "''${pids[$((display - 100))]}" 2>/dev/null; then
            break
          fi
          if timeout 5 xpra info ":$display" > "$display.info" 2> "$display.log" &&
            grep -Eq '^windows\.[0-9]+\.title=' "$display.info"; then
            ready=true
            break
          fi
          sleep 1
        done
        if [[ "$ready" != true ]]; then
          echo "Xpra :$display did not expose an application window" >&2
          cat "$display.info"
          exit 1
        fi
      done
      grep -F 'remote-x11-test' 100.info
      grep -i 'weston' 101.info
      xpra info :100 > /dev/null
      xpra info :101 > /dev/null
      touch "$out"
    ''
