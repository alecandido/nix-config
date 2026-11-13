{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  niri = inputs.self.nixosConfigurations.rose-oasis.config;
  gnome = inputs.self.nixosConfigurations.ocopoli.config;
  disabled =
    (inputs.self.nixosConfigurations.rose-oasis.extendModules {
      modules = [{plan.apps.teams.enable = lib.mkForce false;}];
    }).config;
  other = inputs.self.nixosConfigurations.yukon.config;
  home = config: config.home-manager.users.alessandro;
  hasTeamsRules = config:
    lib.hasInfix ''app-id="^ms-teams$"'' (home config).plan.niri.extraConfig;
  testHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = pkgs.extend (_final: prev: {
      chromium = prev.writeShellScriptBin "chromium" ''
        printf '%s\n' "$@"
      '';
    });
    modules = [
      ../home/teams
      ../home/niri
      {
        home = {
          username = "teams-test";
          homeDirectory = "/tmp/teams-test";
          stateVersion = "26.05";
        };
        plan.teams.enable = true;
      }
    ];
  };
in
  assert (home niri).plan.teams.enable && (home gnome).plan.teams.enable;
  assert niri.services.pipewire.enable && niri.services.pipewire.alsa.enable && niri.services.pipewire.pulse.enable;
  assert gnome.xdg.portal.enable;
  assert lib.elem pkgs.xdg-desktop-portal-gtk niri.xdg.portal.extraPortals;
  assert lib.elem pkgs.xdg-desktop-portal-gnome niri.xdg.portal.extraPortals;
  assert lib.elem pkgs.xdg-desktop-portal-gtk gnome.xdg.portal.extraPortals;
  assert lib.elem pkgs.xdg-desktop-portal-gnome gnome.xdg.portal.extraPortals;
  assert niri.xdg.portal.config.niri."org.freedesktop.impl.portal.ScreenCast" == "gnome";
  assert niri.xdg.portal.config.niri."org.freedesktop.impl.portal.Screenshot" == "gnome";
  assert niri.xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" == "gtk";
  assert niri.xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" == "gnome-keyring";
  assert !(gnome.xdg.portal.config ? niri) && !(other.xdg.portal.config ? niri);
  assert hasTeamsRules niri && !(hasTeamsRules gnome) && !(hasTeamsRules disabled);
  assert !(home disabled).plan.teams.enable && !(home other).plan.teams.enable;
  assert !(disabled.xdg.portal.config.niri ? "org.freedesktop.impl.portal.ScreenCast");
  assert !((home other).xdg.desktopEntries ? ms-teams);
    pkgs.runCommand "teams-check" {} ''
      # Build-time validation also checks the real host's merged KDL.
      test -s ${niri.home-manager.users.alessandro.xdg.configFile."niri/config.kdl".source}
      launcher=${testHome.config.home.path}/bin/ms-teams
      desktop=${testHome.config.home.path}/share/applications/ms-teams.desktop
      grep -Fx 'StartupWMClass=ms-teams' "$desktop"
      grep -Ex 'MimeType=x-scheme-handler/msteams;?' "$desktop"

      "$launcher" > actual
      for flag in \
        '--user-data-dir=/tmp/teams-test/.local/share/teams-profile' \
        '--class=ms-teams' \
        '--ozone-platform=wayland' \
        '--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer,NativeNotifications' \
        '--disable-background-timer-throttling' \
        '--disable-renderer-backgrounding' \
        '--disable-backgrounding-occluded-windows' \
        '--app=https://teams.microsoft.com/v2/'; do
        grep -Fx -- "$flag" actual
      done

      for url in \
        'msteams:/l/meetup-join/meeting?context=%7B%7D&tenantId=example' \
        'msteams://teams.microsoft.com/l/meetup-join/meeting?context=%7B%7D&tenantId=example' \
        'https://teams.microsoft.com/l/meetup-join/meeting?context=%7B%7D&tenantId=example'; do
        "$launcher" "$url" > actual
        grep -Fx -- '--app=https://teams.microsoft.com/l/meetup-join/meeting?context=%7B%7D&tenantId=example' actual
      done
      "$launcher" 'msteams://teams.cloud.microsoft/l/meetup-join/meeting' > actual
      grep -Fx -- '--app=https://teams.cloud.microsoft/l/meetup-join/meeting' actual

      for url in '--no-sandbox' 'https://example.org/' 'msteams://teams.microsoft.com.evil/l/meeting'; do
        if "$launcher" "$url" > actual 2> error; then
          echo "Unexpectedly accepted: $url" >&2
          exit 1
        fi
        test ! -s actual
        grep -F 'unsupported Teams URL' error
      done
      if "$launcher" 'https://teams.microsoft.com/v2/' '--no-sandbox' > actual 2> error; then
        echo "Unexpectedly accepted multiple arguments" >&2
        exit 1
      fi
      grep -F 'Usage: ms-teams' error
      touch "$out"
    ''
