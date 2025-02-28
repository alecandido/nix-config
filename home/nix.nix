{
  pkgs,
  user,
  inputs,
  ...
}: let
  system = pkgs.system;
  devenv = inputs.devenv.packages.${system}.default;
in {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = [user];
  };

  # Useful nix related tools
  home.packages =
    (with pkgs; [
      cachix
      niv
    ])
    ++ [devenv];
}
