{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.plan.niri;
  toml = pkgs.formats.toml {};
  rawConfig = toml.generate "noctalia-config-unchecked.toml" cfg.noctaliaSettings;
in {
  options.plan.niri.noctaliaSettings = lib.mkOption {
    type = toml.type;
    default = {};
    description = "Noctalia settings layered over its built-in defaults; GUI overrides remain available.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.noctalia
      pkgs.ddcutil
    ];

    plan.niri.noctaliaSettings = {
      brightness.enable_ddcutil = lib.mkDefault true;
      location.auto_locate = lib.mkDefault true;
      weather.enabled = lib.mkDefault true;
      calendar.enabled = lib.mkDefault true;
      theme = {
        mode = lib.mkDefault "dark";
        source = lib.mkDefault "builtin";
        builtin = lib.mkDefault "Nord";
      };
      shell = {
        font_family = lib.mkDefault "BlexMono Nerd Font Mono";
        # Do not introduce clipboard history without opting in.
        clipboard_enabled = lib.mkDefault false;
        polkit_agent = lib.mkDefault false;
      };
      widget.workspaces = {
        label_source = lib.mkDefault "name";
        max_label_chars = lib.mkDefault 20;
      };
      lockscreen = {
        enabled = lib.mkDefault true;
        lock_before_suspend = lib.mkDefault true;
        transition = lib.mkDefault [];
      };
      idle = {
        pre_action_fade_seconds = lib.mkDefault 0;
        behavior = {
          lock = {
            enabled = lib.mkDefault true;
            timeout = lib.mkDefault 600;
            action = lib.mkDefault "lock";
          };
          screen-off = {
            enabled = lib.mkDefault true;
            timeout = lib.mkDefault 900;
            locked_timeout = lib.mkDefault 5;
            action = lib.mkDefault "screen_off";
          };
        };
      };
    };

    xdg.configFile."noctalia/config.toml".source = pkgs.runCommand "noctalia-config.toml" {} ''
      ${lib.getExe pkgs.noctalia} config validate ${rawConfig}
      cp ${rawConfig} "$out"
    '';

    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia desktop shell";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = lib.getExe pkgs.noctalia;
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
