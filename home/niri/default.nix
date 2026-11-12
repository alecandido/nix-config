{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.plan.niri;
  font = "BlexMono Nerd Font Mono";
  lock = "${lib.getExe config.programs.swaylock.package} --daemonize";
  outputDirective = output:
    lib.optionalString (output != null) "open-on-output ${builtins.toJSON output}";
in {
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

    xdg.configFile."niri/config.kdl".text =
      builtins.replaceStrings
      [
        "@primary-output@"
        "@secondary-output@"
        "@terminal@"
        "@fuzzel@"
        "@swaylock@"
        "@wpctl@"
        "@brightnessctl@"
      ]
      [
        (outputDirective cfg.primaryOutput)
        (outputDirective cfg.secondaryOutput)
        (lib.getExe config.programs.ghostty.package)
        (lib.getExe config.programs.fuzzel.package)
        (lib.getExe config.programs.swaylock.package)
        "${pkgs.wireplumber}/bin/wpctl"
        (lib.getExe pkgs.brightnessctl)
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

    home.packages = [pkgs.brightnessctl];

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "${font}:size=11";
          terminal = "${lib.getExe config.programs.ghostty.package} -e";
          layer = "overlay";
        };
        colors = {
          background = "2e3440ff";
          text = "d8dee9ff";
          match = "88c0d0ff";
          selection = "434c5eff";
          selection-text = "eceff4ff";
          selection-match = "88c0d0ff";
          border = "88c0d0ff";
        };
        border = {
          width = 2;
          radius = 0;
        };
      };
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = ["graphical-session.target"];
      };
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        spacing = 12;
        modules-left = ["niri/workspaces"];
        modules-center = ["niri/window"];
        modules-right = ["network" "wireplumber" "cpu" "memory" "tray" "clock"];
        "niri/workspaces" = {
          all-outputs = false;
          hide-empty = false;
          format = "{name}";
        };
        "niri/window".max-length = 40;
        network = {
          format-wifi = "{essid}";
          format-ethernet = "{ifname}";
          format-disconnected = "offline";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        wireplumber = {
          format = "vol {volume}%";
          format-muted = "muted";
        };
        cpu = {
          format = "cpu {usage}%";
          interval = 5;
        };
        memory = {
          format = "mem {}%";
          interval = 5;
        };
        tray.spacing = 8;
        clock = {
          format = "{:%a %d %b %H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "${font}";
          font-size: 12px;
          min-height: 0;
        }
        window#waybar {
          background: #2e3440;
          color: #d8dee9;
        }
        #workspaces button {
          padding: 0 8px;
          color: #d8dee9;
          background: transparent;
        }
        #workspaces button.active {
          color: #88c0d0;
          box-shadow: inset 0 -2px #88c0d0;
        }
        #workspaces button.urgent {
          color: #bf616a;
        }
        #clock { padding-right: 8px; }
      '';
    };

    services.mako = {
      enable = true;
      settings = {
        font = "${font} 11";
        anchor = "top-right";
        default-timeout = 5000;
        background-color = "#2e3440";
        text-color = "#d8dee9";
        border-color = "#88c0d0";
        border-size = 2;
        border-radius = 0;
      };
    };
    # Mako's HM module installs D-Bus activation but does not define a user unit.
    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = lib.getExe config.services.mako.package;
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "2e3440";
        font = font;
        indicator-radius = 60;
        ring-color = "88c0d0";
        key-hl-color = "a3be8c";
        inside-color = "2e3440";
        line-color = "2e3440";
        show-failed-attempts = true;
      };
    };
    services.swayidle = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
      timeouts = [
        {
          timeout = 600;
          command = lock;
        }
        {
          timeout = 900;
          command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
          resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
        }
      ];
      events = {
        before-sleep = lock;
        lock = lock;
      };
    };
  };
}
