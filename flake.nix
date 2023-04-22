{
  description = "AleCandido's Nix configs";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Tools
    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = inputs:
    let
      sys = (import ./systems) inputs;
      nixConfigs = (import ./configs/nix.nix) inputs;
    in {
      darwinConfigurations = sys.darwin;

      inherit (nixConfigs) formatter;
    };
}
