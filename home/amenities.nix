{ pkgs, ... }:

{
  home.packages = with pkgs;
  [
    # manipulate images
    imagemagick
    # render images in browser
    chafa
    # render PDF to many formats
    poppler_utils
    # render video thumbnails
    ffmpegthumbnailer
  ];
}
