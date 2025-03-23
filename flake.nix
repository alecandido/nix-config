{
  description = "AleCandido's Nix configs";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Environment/system management
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utilities
    flake-utils.url = "github:numtide/flake-utils";

    # Tools
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    agenix.url = "github:ryantm/agenix";

    # Overlays
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    secrets.url = "git+ssh://git@github.com/alecandido/secrets.git?shallow=1";
  };

  outputs = inputs: let
    sys = (import ./systems) inputs;
    nixConfigs = (import ./top/nix.nix) inputs;
  in {
    nixosConfigurations = sys.nixos;
    darwinConfigurations = sys.darwin;
    homeConfigurations = sys.user;

    inherit (nixConfigs) formatter;

    devShells = (import ./shells) inputs;
  };
}
