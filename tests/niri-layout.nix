{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  home = inputs.self.nixosConfigurations.rose-oasis.config.home-manager.users.alessandro;
  restore = lib.findFirst (package: package.name == "niri-restore-desktop") null home.home.packages;
  desktop = lib.findFirst (package: package.name == "niri-restore-desktop-default.desktop") null home.home.packages;
  alternative = pkgs.writeText "work-layout.json" (builtins.toJSON (
    (builtins.fromJSON (builtins.readFile ../systems/nixos/rose-oasis/home/desktop-layout.json)) // {focus = "firefox";}
  ));
  mockPython = pkgs.writeShellScriptBin "python" ''
    cat "$2"
  '';
  mockNotify = pkgs.writeShellScriptBin "notify-send" ":";
  testHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../home/niri/layout.nix
      {
        options.plan.niri.enable = lib.mkEnableOption "Niri in layout tests";
        config = {
          home = {
            username = "layout-test";
            homeDirectory = "/tmp/layout-test";
            stateVersion = "26.05";
          };
          plan.niri = {
            enable = true;
            desktopLayouts = {
              default = home.plan.niri.desktopLayouts.default;
              work = alternative;
            };
          };
        };
      }
    ];
  };
  testRestore = lib.findFirst (package: package.name == "niri-restore-desktop") null testHome.config.home.packages;
  testDesktops = lib.filter (package: lib.hasPrefix "niri-restore-desktop-" package.name) testHome.config.home.packages;
in
  assert restore != null;
  assert desktop != null;
  assert home.xdg.desktopEntries.niri-restore-desktop-default.exec == "${lib.getExe restore} default";
  assert testHome.config.xdg.desktopEntries.niri-restore-desktop-default.exec == "${lib.getExe testRestore} default";
  assert testHome.config.xdg.desktopEntries.niri-restore-desktop-work.exec == "${lib.getExe testRestore} work";
    pkgs.runCommand "niri-layout-check" {
      nativeBuildInputs = [pkgs.python3];
    } ''
      python ${./niri-layout.py} \
        ${../lib/niri/restore-layout.py} \
        ${../systems/nixos/rose-oasis/home/desktop-layout.json}
      test -x ${restore}/bin/niri-restore-desktop
      test -f ${desktop}/share/applications/niri-restore-desktop-default.desktop

      substitute ${lib.getExe testRestore} launcher \
        --replace-fail "${pkgs.python3}/bin/python" "${mockPython}/bin/python" \
        --replace-fail "${pkgs.libnotify}/bin" "${mockNotify}/bin"
      chmod +x launcher
      launcher="$PWD/launcher"
      "$launcher" > implicit
      "$launcher" default > explicit
      cmp implicit explicit
      cmp implicit ${home.plan.niri.desktopLayouts.default}
      "$launcher" work > selected
      cmp selected ${alternative}

      for name in missing ""; do
        if "$launcher" "$name" > selected 2> error; then
          echo "Unexpectedly accepted layout: $name" >&2
          exit 1
        fi
        test ! -s selected
        grep -F 'Unknown desktop layout:' error
        grep -F 'Configured layouts: default, work' error
      done
      if "$launcher" default work > selected 2> error; then
        echo "Unexpectedly accepted multiple layout arguments" >&2
        exit 1
      fi
      test ! -s selected
      grep -F 'Usage: niri-restore-desktop [layout-name]' error

      for desktop in ${lib.concatStringsSep " " (map (package: "${package}/share/applications/*.desktop") testDesktops)}; do
        entry="$(sed -n 's/^Exec=//p' "$desktop")"
        case "$entry" in
          "${lib.getExe testRestore} default") "$launcher" default > selected; cmp selected implicit ;;
          "${lib.getExe testRestore} work") "$launcher" work > selected; cmp selected ${alternative} ;;
          *) echo "Unexpected launcher entry: $entry" >&2; exit 1 ;;
        esac
      done
      touch "$out"
    ''
