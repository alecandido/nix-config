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
        # Keep the GTK chooser; Home Manager installs Nautilus for browsing.
        useNautilus = false;
      };
      services.displayManager.defaultSession = "niri";
      programs.noctalia.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      security.soteria.enable = true;
      systemd.user.services.polkit-soteria.partOf = ["graphical-session.target"];

      # Niri starts satellite on demand; do not run a separate Xwayland service.
      environment.systemPackages = [pkgs.xwayland-satellite];

      # programs.niri supplies GNOME screencasting, GTK portals and Niri routing.
      xdg.portal.enable = true;
    })
  ];
}
