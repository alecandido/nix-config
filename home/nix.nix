{pkgs, ...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # Useful nix related tools
  home.packages = with pkgs; [
    cachix
  ];

  programs.devenv = {
    enable = true;
    enableNushellIntegration = true;
  };
}
