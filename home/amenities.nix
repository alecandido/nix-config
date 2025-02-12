{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.plan.amenities;
in {
  options.plan.amenities = {
    enable = mkEnableOption "amenities";
  };

  config = {
    home.packages = mkIf cfg.enable (with pkgs; [
      # manipulate images
      imagemagick
      ghostscript
      # render images in browser
      chafa
      # render PDF to many formats
      poppler_utils
      # render video thumbnails
      ffmpegthumbnailer
      # record terminal sessions
      vhs
    ]);
  };
}
