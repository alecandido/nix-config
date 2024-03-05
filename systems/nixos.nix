{
  home-manager,
  nixpkgs,
  ...
} @ inputs: let
  homeMods = user: toggles: ((import ./home).lib.homeMods {
    inherit inputs user toggles;
    home = "/home/${user}";
  });

  instances = {
    ocopoli = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        ./nixos/ocopoli
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" ["amenities" "tex" "neovim.lsp" "gnome"])
        {nixpkgs = (import ../overlays_) inputs [];}
        {networking.hostName = "ocopoli";}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    klondike = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        ./nixos/klondike
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" ["amenities" "tex" "neovim.lsp"])
        {nixpkgs = (import ../overlays_) inputs [];}
        {networking.hostName = "klondike";}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    villarose = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        ./nixos/villarose
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" ["amenities" "neovim.lsp"])
        {nixpkgs = (import ../overlays_) inputs [];}
        {networking.hostName = "villarose";}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
    };

    yukon = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        ./nixos/yukon
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" ["amenities" "neovim.lsp" "gnome"])
        {nixpkgs = (import ../overlays_) inputs [];}
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
