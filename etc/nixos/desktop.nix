{
  config,
  lib,
  pkgs,
  ...
}: let
  niri = config.plan.desktop == "niri";
  apps = {
    zoom = pkgs.zoom-us;
    spotify = pkgs.spotify;
    beeper = pkgs.beeper;
    fractal = pkgs.fractal;
    xournalpp = pkgs.xournalpp;
  };
in {
  imports = [./gnome.nix ./teams.nix];

  options.plan.desktop = lib.mkOption {
    type = lib.types.enum ["gnome" "niri"];
    default = "gnome";
    description = "Desktop session, shared with Home Manager.";
  };

  options.plan.apps =
    lib.mapAttrs (name: _: {
      enable = lib.mkEnableOption name;
    })
    apps;

  config = lib.mkMerge [
    {
      environment.systemPackages =
        lib.attrValues (lib.filterAttrs (name: _: config.plan.apps.${name}.enable) apps);

      services.displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      hardware.i2c.enable = true;

      home-manager.sharedModules = [
        {
          plan.niri.enable = niri;
          plan.vicinae.enable = true;
        }
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
