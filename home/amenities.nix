{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;
  cfg = config.plan.amenities;
in {
  options.plan = {
    amenities.enable = mkEnableOption "amenities";
    recording.enable = mkEnableOption "terminal recording with VHS";
  };

  config = {
    home.packages =
      lib.optionals cfg.enable (with pkgs; [
        # manipulate images
        imagemagick
        ghostscript
        # render images in browser
        chafa
        # render PDF to many formats
        poppler-utils
        # render video thumbnails
        ffmpegthumbnailer
      ])
      ++ lib.optional config.plan.recording.enable pkgs.vhs;
  };
}
