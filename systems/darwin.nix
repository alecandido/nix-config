{ darwin
, home-manager
, ...
} @ inputs:
let
  homeMods = user: ((import ./home).lib.homeMods {
    inherit inputs user;
    home = "/Users/${user}";
  });

  nixpkgs = (import ../overlays_) inputs;

  instances = {
    donaldville = darwin.lib.darwinSystem {
      modules = [
        ../etc/darwin
        home-manager.darwinModules.home-manager
        (homeMods "alessandro")
        { nixpkgs = nixpkgs [ ]; }
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = { inherit inputs; };
      system = "aarch64-darwin";
    };
  };
in
{
  donaldville = instances.donaldville;
  ac-donaldville = instances.donaldville;
}
