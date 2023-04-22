{
  imports = [ ./tools.nix ./nix.nix ];

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
}
