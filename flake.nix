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
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Tools
    devenv.url = "github:cachix/devenv";
    agenix.url = "github:ryantm/agenix";

    # Overlays
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
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.devenv.flakeModule];
      systems = ["x86_64-linux" "aarch64-darwin"];

      flake = {
        nixosConfigurations = sys.nixos;
        darwinConfigurations = sys.darwin;
        homeConfigurations = sys.user;

        inherit (nixConfigs) formatter;
      };

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        imports = [./shells];
      };
    };
}
