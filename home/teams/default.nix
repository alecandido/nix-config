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
    xdg.desktopEntries.ms-teams = {
      name = "Microsoft Teams";
      comment = "Microsoft Teams in an isolated Chromium profile";
      exec = "${lib.getExe teams} %u";
      icon = "chromium";
      categories = ["Network" "InstantMessaging"];
      mimeType = ["x-scheme-handler/msteams"];
      settings.StartupWMClass = "ms-teams";
    };
    xdg.mimeApps = {
      enable = true;
      defaultApplications."x-scheme-handler/msteams" = ["ms-teams.desktop"];
    };
  };
}
