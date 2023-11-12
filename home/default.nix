{ user, ... }: {
  imports = [
    ./aliases
    ./git
    ./kerberos
    ./neovim
    ./ssh
    ./zellij
    ./amenities.nix
    ./build.nix
    ./javascript.nix
    ./nix.nix
    ./python.nix
    ./tex.nix
    ./tools.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  home.username = user;
  home.stateVersion = "23.05";
}
