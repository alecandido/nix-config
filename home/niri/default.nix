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
  imports = [./noctalia.nix ./layout.nix];

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

    home.packages = [
      pkgs.nautilus
      pkgs.papers
    ];
    plan.niri.noctaliaSettings.widget.launcher.actions.left =
      lib.mkDefault "exec ${lib.getExe pkgs.vicinae} toggle";
    xdg.configFile."niri-mimeapps.list".text = ''
      [Default Applications]
      inode/directory=org.gnome.Nautilus.desktop;
      application/pdf=org.gnome.Papers.desktop;
    '';

    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        window-title-basename = true;
        statusbar-home-tilde = true;
        font = "BlexMono Nerd Font Mono 10";
        default-bg = "#2e3440";
        default-fg = "#d8dee9";
        statusbar-bg = "#3b4252";
        statusbar-fg = "#d8dee9";
        inputbar-bg = "#2e3440";
        inputbar-fg = "#eceff4";
        notification-bg = "#3b4252";
        notification-fg = "#eceff4";
        notification-error-bg = "#bf616a";
        notification-error-fg = "#eceff4";
        notification-warning-bg = "#ebcb8b";
        notification-warning-fg = "#2e3440";
        highlight-color = "rgba(136,192,208,0.5)";
        highlight-active-color = "rgba(129,161,193,0.5)";
        completion-bg = "#3b4252";
        completion-fg = "#d8dee9";
        completion-highlight-bg = "#88c0d0";
        completion-highlight-fg = "#2e3440";
        index-bg = "#2e3440";
        index-fg = "#d8dee9";
        index-active-bg = "#88c0d0";
        index-active-fg = "#2e3440";
        recolor = false;
        recolor-lightcolor = "#2e3440";
        recolor-darkcolor = "#eceff4";
        recolor-keephue = true;
      };
    };

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
