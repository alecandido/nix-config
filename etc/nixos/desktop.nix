{
  config,
  lib,
  pkgs,
  ...
}: let
  niri = config.plan.desktop == "niri";
in {
  imports = [./gnome.nix];

  options.plan.desktop = lib.mkOption {
    type = lib.types.enum ["gnome" "niri"];
    default = "gnome";
    description = "Desktop session, shared with Home Manager.";
  };

  config = lib.mkMerge [
    {
      services.displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      hardware.i2c.enable = true;

      home-manager.sharedModules = [
        {plan.niri.enable = niri;}
      ];
    }
    (lib.mkIf niri {
      programs.niri = {
        enable = true;
        # Use the GTK file chooser rather than installing Nautilus.
        useNautilus = false;
      };
      services.displayManager.defaultSession = "niri";
      services.gnome.gnome-keyring.enable = true;
      security.soteria.enable = true;
      systemd.user.services.polkit-soteria.partOf = ["graphical-session.target"];
      security.pam.services.swaylock = {};

      # Niri starts satellite on demand; do not run a separate Xwayland service.
      environment.systemPackages = [pkgs.xwayland-satellite];

      # programs.niri supplies GNOME screencasting, GTK portals and Niri routing.
      xdg.portal.enable = true;
    })
  ];
}
