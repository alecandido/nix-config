{
  # config,
  # lib,
  pkgs,
  ...
}: let
  # inherit (lib) mkIf;
  # cfg = config.plan.dconf;
in {
  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false; # TODO: mkIf cfg.server (builtins.trace "ciao" false);
  };

  environment = {
    systemPackages = with pkgs; [
      gnome-browser-connector
      # gnome-extension-manager
      gnomeExtensions.appindicator
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
