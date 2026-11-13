{
  config,
  lib,
  pkgs,
  ...
}: let
  teams = pkgs.writeShellApplication {
    name = "ms-teams";
    text = ''
      if (( $# > 1 )); then
        echo "Usage: ms-teams [Teams URL]" >&2
        exit 64
      fi

      url="''${1:-https://teams.microsoft.com/v2/}"
      case "$url" in
        msteams://teams.microsoft.com/*|msteams://teams.cloud.microsoft/*)
          url="https://''${url#msteams://}"
          ;;
        msteams:/l/*)
          url="https://teams.microsoft.com/''${url#msteams:/}"
          ;;
        https://teams.microsoft.com/*|https://teams.cloud.microsoft/*)
          ;;
        *)
          echo "ms-teams: unsupported Teams URL: $url" >&2
          exit 64
          ;;
      esac

      exec ${lib.getExe pkgs.chromium} \
        --user-data-dir=${lib.escapeShellArg "${config.xdg.dataHome}/teams-profile"} \
        --class=ms-teams \
        --ozone-platform=wayland \
        --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer,NativeNotifications \
        --disable-background-timer-throttling \
        --disable-renderer-backgrounding \
        --disable-backgrounding-occluded-windows \
        --app="$url"
    '';
  };
in {
  imports = [./niri.nix];

  options.plan.teams.enable = lib.mkEnableOption "the isolated Chromium Microsoft Teams client";

  config = lib.mkIf config.plan.teams.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "plan.teams" pkgs lib.platforms.linux)
    ];

    home.packages = [teams];
    xdg.dataFile."icons/hicolor/scalable/apps/ms-teams.svg".source = ./ms-teams.svg;
    xdg.desktopEntries.ms-teams = {
      name = "Microsoft Teams";
      comment = "Microsoft Teams in an isolated Chromium profile";
      exec = "${lib.getExe teams} %u";
      icon = "${./ms-teams.svg}";
      categories = ["Network" "InstantMessaging"];
      mimeType = ["x-scheme-handler/msteams"];
      settings.StartupWMClass = "ms-teams";
    };
    xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" =
      lib.mkIf config.xdg.mimeApps.enable ["ms-teams.desktop"];
    home.activation.teamsMimeHandler = lib.mkIf (!config.xdg.mimeApps.enable) (
      lib.hm.dag.entryAfter ["linkGeneration"] ''
        run mkdir -p "''${XDG_CONFIG_HOME:-$HOME/.config}"
        run ${pkgs.xdg-utils}/bin/xdg-mime default ms-teams.desktop x-scheme-handler/msteams
        if [[ ! -v DRY_RUN ]]; then
          teams_handler="$(${pkgs.xdg-utils}/bin/xdg-mime query default x-scheme-handler/msteams)"
          if [[ "$teams_handler" != ms-teams.desktop ]]; then
            echo "Failed to register ms-teams.desktop as the msteams URL handler" >&2
            exit 1
          fi
        fi
      ''
    );
  };
}
