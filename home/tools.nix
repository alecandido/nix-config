{ pkgs, lib, ... }:

{
  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      curl
      wget

      # Tools
      exa
      jq
      ripgrep
      fd
      ripgrep-all
      gh
    ] ++ lib.optionals stdenv.isDarwin [ m-cli ];

  # XDG
  xdg.enable = true;

  # Starship
  programs.starship = {
    enable = true;
    settings = { hostname.ssh_only = false; };
  };

  # Zellij
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      theme = "nord";
    };
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Htop
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };
}
