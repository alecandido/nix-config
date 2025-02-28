{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.system;
  devenv = inputs.devenv.packages.${system}.default;
in {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # Useful nix related tools
  home.packages =
    (with pkgs; [
      cachix
      niv
    ])
    ++ [devenv];
}
