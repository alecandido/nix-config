{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stylua
    alejandra
  ];
}
