{
  config,
  lib,
  ...
}: {
  options.plan.apps.teams.enable = lib.mkEnableOption "Microsoft Teams";

  config = lib.mkIf config.plan.apps.teams.enable (lib.mkMerge [
    {
      home-manager.sharedModules = [{plan.teams.enable = true;}];

      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
      # Both supported desktop modules already supply GTK and GNOME backends.
      xdg.portal.enable = lib.mkDefault true;
    }
    (lib.mkIf (config.plan.desktop == "niri") {
      xdg.portal = {
        config.niri = {
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
        };
      };
    })
  ]);
}
