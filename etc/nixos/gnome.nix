{pkgs, ...}: {
  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false; # TODO: mkIf cfg.server (builtins.trace "ciao" false);
  };

  hardware.i2c.enable = true;

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
}
