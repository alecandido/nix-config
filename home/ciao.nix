{ config, pkgs, lib, ... }:

{
  # XDG
  xdg.enable = builtins.trace config false;

  # Starship
  programs.starship.enable = true;
  programs.starship.settings = {
    hostname.ssh_only = false;
  };

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.zsh.enable = true; # TODO: duplicated, drop from here
  
  # Zellij
  programs.zellij.enable = true;
  programs.zellij.settings = {
    simplified_ui = true;
    theme = "nord";
  };

  # Git
  programs.git.enable = true;
  programs.git.ignores = [
    ".DS_Store"
  ];

  # Htop
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  home.packages = with pkgs; [
    # Useful nix related tools
    cachix
    # config.devenv.packages.x86_64-linux.devenv
    niv
  ] ++ lib.optionals stdenv.isDarwin [
    # https://github.com/rgcr/m-cli
    m-cli
  ];

}
