{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) home-manager nixpkgs self;

  overlays_ = extra: (import ../../overlays_) inputs extra;

  mkNixos = name: (let
    path = ./. + ("/" + name);
    homeMods = lib.homeMods (let
      config = import "${path}/home";
      user = config.user;
    in {
      inherit inputs;
      homeRoot = "${self}/home";
      config = config // {home = "/home/${user}";};
    });
  in
    nixpkgs.lib.nixosSystem {
      modules = [
        {networking.hostName = name;}
        "${self}/etc/nixos"
        path
        home-manager.nixosModules.home-manager
        homeMods
        inputs.agenix.nixosModules.default
        {nixpkgs = overlays_ [];}
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
  };
in {
  ocopoli = instances.ocopoli;
  klondike = instances.klondike;
  villarose = instances.villarose;
  yukon = instances.yukon;
}
