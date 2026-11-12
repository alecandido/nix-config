{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.plan.niri;
  outputDirective = output:
    lib.optionalString (output != null) "open-on-output ${builtins.toJSON output}";
in {
  imports = [./noctalia.nix];

  options.plan.niri = {
    enable = lib.mkEnableOption "the minimal Niri desktop";
    primaryOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Exact Niri output identity for workspaces 1-3; null leaves placement automatic.";
    };
    secondaryOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Exact Niri output identity for workspaces 4-5; null leaves placement automatic.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific KDL, such as output modes, scales and positions.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "plan.niri" pkgs lib.platforms.linux)
    ];

    home.packages = [pkgs.nautilus];
    plan.niri.noctaliaSettings.widget.launcher.actions.left =
      lib.mkDefault "exec ${lib.getExe pkgs.vicinae} toggle";
    xdg.configFile."niri-mimeapps.list".text = ''
      [Default Applications]
      inode/directory=org.gnome.Nautilus.desktop;
    '';

    home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
    };
    gtk = {
      enable = true;
      font = {
        package = pkgs.inter;
        name = "Inter";
        size = 10;
      };
    };

    xdg.configFile."niri/config.kdl".text =
      builtins.replaceStrings
      [
        "@primary-output@"
        "@secondary-output@"
        "@terminal@"
        "@noctalia@"
        "@vicinae@"
        "@cursor-theme@"
        "@cursor-size@"
      ]
      [
        (outputDirective cfg.primaryOutput)
        (outputDirective cfg.secondaryOutput)
        (lib.getExe config.programs.ghostty.package)
        (lib.getExe pkgs.noctalia)
        (lib.getExe pkgs.vicinae)
        (builtins.toJSON config.home.pointerCursor.name)
        (toString config.home.pointerCursor.size)
      ]
      (builtins.readFile ./config.kdl)
      + "\n"
      + cfg.extraConfig;

    xdg.configFile."niri/config.kdl".source = let
      unchecked = pkgs.writeText "niri-config-unchecked.kdl" config.xdg.configFile."niri/config.kdl".text;
    in
      pkgs.runCommand "niri-config.kdl" {} ''
        ${pkgs.niri}/bin/niri validate --config ${unchecked}
        cp ${unchecked} "$out"
      '';
  };
}
