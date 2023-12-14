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

  # nixpkgs = (import ../overlays_) inputs;

  instances = {
    ocopoli = nixpkgs.lib.nixosSystem {
      modules = [
        ../etc/nixos
        home-manager.nixosModules.home-manager
        (homeMods "alessandro" [ "amenities" "tex" "neovim.lsp" ])
        { nixpkgs = nixpkgs [ ]; }
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };
  };
in
{
  # ocopoli = instances.ocopoli;
  ocopoli = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nix Module,
          /etc/nixos/configuration.nix
        ];
  };
}

