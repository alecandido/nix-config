{ user, ... }:

{
  imports = [
    ./aliases
    ./git
    ./neovim
    ./javascript.nix
    ./python.nix
    ./rust.nix
    ./nix.nix
    ./tex.nix
    ./tools.nix
    ./zsh.nix
  ];

  programs.zsh.enable = true;

  home.username = user;
  home.stateVersion = "22.11";
  home.sessionPath = [ "/run/current-system/sw/bin" ];
}
