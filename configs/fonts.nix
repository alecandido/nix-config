{ pkgs, ... }:

{
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [ ];
}
