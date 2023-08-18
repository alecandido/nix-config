{ pkgs, user, ... }:

{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    trusted-users = [ "root" user ];
  };

  # Useful nix related tools
  home.packages = with pkgs; [
    cachix
    devenv
    niv
  ];
}
