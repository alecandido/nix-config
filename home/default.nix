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
  home.stateVersion = "23.05";
  # TODO: understand why the following is required
  home.sessionPath = [ "$HOME/.nix-profile/bin" ];
}
