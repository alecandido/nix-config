{
  home-manager,
  nixpkgs,
  ...
} @ inputs: let
  commonMods = [
    ../../etc/nixos
    home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
  ];
  homeMods = user: toggles: ((import ../home).lib.homeMods {
    inherit inputs user toggles;
    home = "/home/${user}";
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

    villarose = nixpkgs.lib.nixosSystem {
      modules =
        commonMods
        ++ [
          ./villarose
          (homeMods "alessandro" ["amenities" "neovim.lsp" "gnome" "server"])
          {nixpkgs = overlays_ [];}
          {networking.hostName = "villarose";}
        ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    yukon = nixpkgs.lib.nixosSystem {
      modules =
        commonMods
        ++ [
          ./yukon
          (homeMods "alessandro" ["amenities" "neovim.lsp" "gnome" "server" "thunderbird"])
          {nixpkgs = overlays_ [];}
          {networking.hostName = "yukon";}
        ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };
  };
in {
  ocopoli = instances.ocopoli;
  klondike = instances.klondike;
  villarose = instances.villarose;
  yukon = instances.yukon;
}
