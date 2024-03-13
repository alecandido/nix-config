{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin home-manager self;

  mkDarwin = name: (let
    path = ./. + ("/" + name);
    homeMods = lib.homeMods (let
      config = import "${path}/home";
      user = config.user;
    in {
      inherit inputs;
      homeRoot = "${self}/home";
      config = config // {home = "/Users/${user}";};
    });
  in
    darwin.lib.darwinSystem {
      modules = [
        {networking.hostName = name;}
        "${self}/etc/darwin"
        path
        home-manager.darwinModules.home-manager
        homeMods
        inputs.agenix.darwinModules.default
        lib.commonMods
        {nixpkgs.overlays = [inputs.nixpkgs-firefox-darwin.overlay];}
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
