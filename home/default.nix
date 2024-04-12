{
  user,
  extraHomeModules,
  inputs,
  ...
}: {
  imports =
    [
      ./aliases
      ./cheats
      ./git
      ./kerberos
      ./mail
      ./neovim
      ./python
      ./ssh
      ./zellij
      ./amenities.nix
      ./build.nix
      ./dconf.nix
      ./firefox.nix
      ./nix.nix
      ./tex.nix
      ./tools.nix
      ./zsh.nix
      inputs.agenix.homeManagerModules.age
    ]
    ++ extraHomeModules;

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.username = user;
  home.stateVersion = "23.11";
}
