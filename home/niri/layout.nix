{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.plan.niri;
  restore = pkgs.writeShellApplication {
    name = "niri-restore-desktop";
    runtimeInputs = [pkgs.niri pkgs.gtk3 pkgs.libnotify];
    text = ''
      if (( $# > 1 )); then
        echo "Usage: niri-restore-desktop [layout-name]" >&2
        exit 64
      fi

      layout_name="''${1-default}"
      case "$layout_name" in
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
          ${lib.escapeShellArg name}) layout=${lib.escapeShellArg "${path}"} ;;
        '')
        cfg.desktopLayouts)}
        *)
          printf 'Unknown desktop layout: %s\n' "$layout_name" >&2
          echo ${lib.escapeShellArg "Configured layouts: ${lib.concatStringsSep ", " (lib.attrNames cfg.desktopLayouts)}"} >&2
          exit 64
          ;;
      esac

      if ${pkgs.python3}/bin/python ${../../lib/niri/restore-layout.py} "$layout"; then
        notify-send "Desktop layout restored: $layout_name"
      else
        notify-send --urgency=critical "Desktop layout restoration failed" \
          "Run niri-restore-desktop in a terminal for details."
        exit 1
      fi
    '';
  };
in {
  options.plan.niri.desktopLayouts = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = {};
    description = "Named JSON layouts restored on demand by niri-restore-desktop [name], defaulting to default; never started automatically.";
    example = lib.literalExpression ''
      {
        default = ./desktop-layout.json;
        work = ./work-layout.json;
      }
    '';
  };

  config = lib.mkIf (cfg.enable && cfg.desktopLayouts != {}) {
    assertions = [
      {
        assertion = cfg.desktopLayouts ? default;
        message = "plan.niri.desktopLayouts must contain a default layout.";
      }
      {
        assertion = lib.all (name: builtins.match "[A-Za-z0-9][A-Za-z0-9_-]*" name != null) (lib.attrNames cfg.desktopLayouts);
        message = "plan.niri.desktopLayouts names must start with a letter or digit and contain only letters, digits, underscores, or hyphens.";
      }
    ];

    home.packages = [restore];
    xdg.desktopEntries = lib.mapAttrs' (name: _:
      lib.nameValuePair "niri-restore-desktop-${name}" {
        name = "Restore Desktop Layout: ${name}";
        comment = "Open the saved set of applications and arrange their windows";
        exec = "${lib.getExe restore} ${name}";
        icon = "view-restore";
        categories = ["Utility"];
        settings.Keywords = "Niri;Layout;Workspace;Restore;";
      })
    cfg.desktopLayouts;
  };
}
