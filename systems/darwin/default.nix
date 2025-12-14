{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin home-manager self;

  mkDarwin = name: (let
    config = import "${path}/home";
    user = config.user;
    path = ./. + ("/" + name);
    homeMods = lib.homeMods {
      inherit inputs;
      homeRoot = "${self}/home";
      config = config // {home = "/Users/${user}";};
    };
  in
    darwin.lib.darwinSystem {
      modules = [
        {
          networking.hostName = name;
          nix.settings.allowed-users = [user];
        }
        "${self}/etc/darwin"
        path
        home-manager.darwinModules.home-manager
        homeMods
        inputs.agenix.darwinModules.default
        lib.commonMods
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "aarch64-darwin";
    });

  instances = {
    donaldville = mkDarwin "donaldville";
  };
in {
  donaldville = instances.donaldville;
  ac-donaldville = instances.donaldville;
}
