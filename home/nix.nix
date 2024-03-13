{
  pkgs,
  user,
  inputs,
  ...
}: let
  system = pkgs.system;
  devenv = inputs.devenv.packages."${system}".default;
in {
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes" "repl-flake"];
    trusted-users = ["root" user];
  };

  # Useful nix related tools
  home.packages =
    (with pkgs; [
      cachix
      niv
    ])
    ++ [devenv];
}
