{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) home-manager nixpkgs self;
  commonMods = [
    ../../etc/nixos
    home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
  ];
  homeMods = config: (lib.homeMods (let
    user = config.user;
  in {
    inherit inputs;
    homeRoot = "${self}/home";
    config = config // {home = "/home/${user}";};
  }));

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
        "${self}/etc/nixos"
        home-manager.nixosModules.home-manager
        path
        homeMods
        inputs.agenix.nixosModules.default
        {nixpkgs = overlays_ [];}
        {networking.hostName = name;}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    });

  overlays_ = extra: (import ../../overlays_) inputs extra;

  instances = {
    ocopoli = nixpkgs.lib.nixosSystem {
      modules =
        commonMods
        ++ [
          ./ocopoli
          (homeMods "alessandro" ["amenities" "tex" "neovim.lsp" "gnome" "thunderbird"])
          {nixpkgs = overlays_ [];}
          {networking.hostName = "ocopoli";}
        ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    klondike = nixpkgs.lib.nixosSystem {
      modules =
        commonMods
        ++ [
          ./klondike
          (homeMods "alessandro" ["amenities" "tex" "neovim.lsp"])
          {nixpkgs = [];}
          {networking.hostName = "klondike";}
        ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    villarose = mkNixos "villarose";
    yukon = mkNixos "yukon";
  };
in {
  ocopoli = instances.ocopoli;
  klondike = instances.klondike;
  villarose = instances.villarose;
  yukon = instances.yukon;
}
