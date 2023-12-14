{ darwin
, home-manager
, nixpkgs
, ...
} @ inputs:
let
  homeMods = user: toggles: ((import ./home).lib.homeMods {
    inherit inputs user toggles;
    home = "/home/${user}";
  });

  instances = {
    ocopoli = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" [ "amenities" "tex" "neovim.lsp" ])
        { nixpkgs = (import ../overlays_) inputs [ ]; }
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };
  };
in
{
  ocopoli = instances.ocopoli;
}

