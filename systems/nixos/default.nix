{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) home-manager nixpkgs self;

  mkNixos = name: (let
    config = import "${path}/home";
    user = config.user;
    path = ./. + ("/" + name);
    homeMods = lib.homeMods {
      inherit inputs;
      homeRoot = "${self}/home";
      config = config // {home = "/home/${user}";};
    };
  in
    nixpkgs.lib.nixosSystem {
      modules = [
        {
          networking.hostName = name;
          nix.settings.trusted-users = [user];
        }
        "${self}/etc/nixos"
        path
        home-manager.nixosModules.home-manager
        homeMods
        lib.commonMods
        inputs.agenix.nixosModules.default
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    });

  instances = {
    ocopoli = mkNixos "ocopoli";
    klondike = mkNixos "klondike";
    villarose = mkNixos "villarose";
    yukon = mkNixos "yukon";
    killmotor = mkNixos "killmotor";
    umbrellastan = mkNixos "umbrellastan";
  };
in {
  ocopoli = instances.ocopoli;
  klondike = instances.klondike;
  villarose = instances.villarose;
  yukon = instances.yukon;
  killmotor = instances.killmotor;
  umbrellastan = instances.umbrellastan;
}
