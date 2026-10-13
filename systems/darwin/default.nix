{
  inputs,
  lib,
  ...
}:
let
  inherit (inputs) home-manager self darwin;
  darwinInputs = inputs // {
    nixpkgs = inputs.nixpkgs-darwin;
  };

  mkDarwin =
    name:
    (
      let
        config = import "${path}/home";
        user = config.user;
        path = ./. + ("/" + name);
        homeMods = lib.homeMods {
          inputs = darwinInputs;
          homeRoot = "${self}/home";
          config = config // {
            home = "/Users/${user}";
          };
        };
      in
      darwin.lib.darwinSystem {
        modules = [
          {
            networking.hostName = name;
            nix.settings.allowed-users = [ user ];
          }
          "${self}/etc/darwin"
          path
          home-manager.darwinModules.home-manager
          homeMods
          lib.commonMods
          inputs.agenix.darwinModules.default
        ];

        # Give `inputs` access to all nix-darwin modules
        specialArgs = { inputs = darwinInputs; };
        system = "aarch64-darwin";
      }
    );

  instances = {
    donaldville = mkDarwin "donaldville";
  };
in
{
  donaldville = instances.donaldville;
  ac-donaldville = instances.donaldville;
}
