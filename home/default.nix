{ user, ... }:

{
  imports = [
    ./nix.nix
    ./aliases
    ./git
    ./neovim
    ./nix.nix
    ./tools.nix
  ];

  programs.zsh.enable = true;

  home.username = user;
  home.stateVersion = "22.11";
  home.sessionPath = [ "/run/current-system/sw/bin" ];
}
