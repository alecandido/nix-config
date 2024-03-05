{user, ...}: {
  imports = [
    ./aliases
    ./cheats
    ./git
    ./kerberos
    ./neovim
    ./python
    ./ssh
    ./zellij
    ./amenities.nix
    ./build.nix
    ./gnome.nix
    ./nix.nix
    ./tex.nix
    ./tools.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  home.username = user;
  home.stateVersion = "23.05";
}
