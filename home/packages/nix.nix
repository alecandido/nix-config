# Useful nix related tools
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cachix
    devenv
    niv
  ];

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
