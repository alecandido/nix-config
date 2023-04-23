{
  description = "AleCandido's Nix configs";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager";
    # TODO: make system dependent
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Tools
    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = inputs:
    let
      sys = (import ./systems) inputs;
      nixConfigs = (import ./nix.nix) inputs;
    in
    {
      darwinConfigurations = sys.darwin;

      inherit (nixConfigs) formatter;
    };
}
