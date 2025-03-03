{
  user,
  extraHomeModules,
  inputs,
  ...
}: {
  imports =
    [
      ./cheats
      ./git
      ./kerberos
      ./mail
      ./neovim
      ./python
      ./shell
      ./ssh
      ./xournalpp
      ./zellij
      ./amenities.nix
      ./build.nix
      ./dconf.nix
      ./firefox.nix
      ./nix.nix
      ./tex.nix
      ./tools.nix
      inputs.agenix.homeManagerModules.age
    ]
    ++ extraHomeModules;

  programs.home-manager.enable = true;

  home.username = user;
  home.stateVersion = "23.11";
}
