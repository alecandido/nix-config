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
    ./tools.nix
  ];

  programs.zsh.enable = true;

  home.username = user;
  home.stateVersion = "22.11";
  home.sessionPath = [ "/run/current-system/sw/bin" ];
}
