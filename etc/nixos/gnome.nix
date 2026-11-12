{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.plan.desktop == "gnome") {
    # Enable the GNOME Desktop Environment.
    services.desktopManager.gnome.enable = true;
    environment = {
      systemPackages = with pkgs; [
        gnome-browser-connector
        # gnome-extension-manager
        gnomeExtensions.appindicator
        gnomeExtensions.brightness-control-using-ddcutil
        gnomeExtensions.emoji-copy
        gnomeExtensions.tiling-shell
      ];

      gnome.excludePackages = with pkgs; [
        epiphany
        gnome-contacts
        gnome-maps
        gnome-music
        geary
        seahorse
      ];
    };
  };
}
