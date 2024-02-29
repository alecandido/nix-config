{
  pkgs,
  toggles,
  ...
}: let
  amenities = builtins.elem "amenities" toggles;
in {
  home.packages = with pkgs;
    if amenities
    then [
      # manipulate images
      imagemagick
      ghostscript
      # render images in browser
      chafa
      # render PDF to many formats
      poppler_utils
      # render video thumbnails
      ffmpegthumbnailer
    ]
    else [];
}
