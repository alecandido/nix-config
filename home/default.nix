{ config, pkgs, user, ... }:

{
  imports = [
    ./packages
    ./nix.nix
    ./aliases
    # (import ./packages.nix)
    # (import ./neovim.nix)
  ];

  programs.zsh.enable = true;

  home.username = user;
  home.stateVersion = "22.11";
  home.sessionPath = [ "/run/current-system/sw/bin" ];
}
