{
  inputs,
  pkgs,
}: let
  home = enabled:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../home/qibocamp.nix
        {
          home = {
            username = "qibocamp-test";
            homeDirectory = "/home/qibocamp-test";
            stateVersion = "26.05";
          };
          plan.qibocamp.enable = enabled;
        }
      ];
    }).config;
  enabled = home true;
  disabled = home false;
  launcher = pkgs.lib.findFirst (p: p.name == "qibocamp-launcher") null enabled.home.packages;
in
  assert launcher != null;
  assert enabled.xdg.desktopEntries.qibocamp-launcher.exec == "${launcher}/bin/qibocamp-launcher";
  assert !(disabled.xdg.desktopEntries ? qibocamp-launcher);
  assert !(pkgs.lib.any (p: p.name == "qibocamp-launcher") disabled.home.packages);
    pkgs.runCommand "qibocamp-check" {
      nativeBuildInputs = [pkgs.python3];
    } ''
      export PYTHONDONTWRITEBYTECODE=1
      python ${./qibocamp.py} ${../lib/qibocamp/launcher.py}
      test -x ${launcher}/bin/qibocamp-launcher
      test -f ${enabled.home.path}/share/applications/qibocamp-launcher.desktop
      touch "$out"
    ''
