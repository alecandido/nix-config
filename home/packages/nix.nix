{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Useful nix related tools
    cachix
    inputs.devenv.packages.aarch64-darwin.devenv
    niv
  ];
}
