{
  config,
  lib,
  pkgs,
  ...
}: let
  launcher = pkgs.writeShellApplication {
    name = "qibocamp-launcher";
    runtimeInputs = [pkgs.nix pkgs.zenity];
    text = ''
      exec ${pkgs.python3}/bin/python ${../lib/qibocamp/launcher.py}
    '';
  };
in {
  options.plan.qibocamp.enable = lib.mkEnableOption ''
    the runtime-configured Qibocamp source chooser, retaining the last prepared
    package for launch without Nix. Sources must provide bin/qibocamp-desktop
    through a flake package and have locked inputs
  '';

  config = lib.mkIf config.plan.qibocamp.enable {
    assertions = [(lib.hm.assertions.assertPlatform "plan.qibocamp" pkgs lib.platforms.linux)];
    home.packages = [launcher];
    xdg.desktopEntries.qibocamp-launcher = {
      name = "Qibocamp";
      comment = "Launch the last prepared Qibocamp build or choose a source";
      exec = lib.getExe launcher;
      icon = "applications-science";
      categories = ["Science" "Development"];
      settings.Keywords = "Qibocal;Calibration;Qibo;";
    };
  };
}
