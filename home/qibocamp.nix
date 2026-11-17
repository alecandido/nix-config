{
  config,
  lib,
  pkgs,
  ...
}: let
  icon = pkgs.fetchurl {
    name = "qibocamp.svg";
    url = "https://raw.githubusercontent.com/qiboteam/qibocamp/c7d492e4096148b6d520fcde3f5335f8e379757d/launcher/src-tauri/icon.svg";
    hash = "sha256-Lk+RQ+TaMjgDg0PjAGfUOlOslLMGqg0stdPqv9DuqoU=";
  };
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
      icon = "${icon}";
      categories = ["Science" "Development"];
      settings.Keywords = "Qibocal;Calibration;Qibo;";
    };
  };
}
