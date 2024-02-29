{
  description = "AleCandido's Nix configs";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake utilities
    flake-utils.url = "github:numtide/flake-utils";

    # Tools
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs: let
    sys = (import ./systems) inputs;
    nixConfigs = (import ./top/nix.nix) inputs;
  in {
    darwinConfigurations = sys.darwin;
    homeConfigurations = sys.home;
    nixosConfigurations = sys.nixos;

    inherit (nixConfigs) formatter;

    devShells = (import ./shells) inputs;
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };
}
