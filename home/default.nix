{
  user,
  extraHomeModules,
  ...
}: {
  imports =
    [
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
      ./dconf.nix
      ./firefox.nix
      ./mail.nix
      ./nix.nix
      ./tex.nix
      ./tools.nix
      ./zsh.nix
    ]
    ++ extraHomeModules;

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.username = user;
  home.stateVersion = "23.11";
}
