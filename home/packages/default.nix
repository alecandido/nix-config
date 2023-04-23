{
  imports = [ ./git ./nix.nix ./tools.nix ];

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

  # Htop
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };
}
