{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin home-manager;

  homeMods = user: toggles: (lib.homeMods {
    inherit inputs user toggles;
    home = "/Users/${user}";
  });

  nixpkgs = (import ../overlays_) inputs;

  instances = {
    donaldville = darwin.lib.darwinSystem {
      modules = [
        ../etc/darwin
        home-manager.darwinModules.home-manager
        (homeMods "alessandro" ["amenities" "tex" "neovim.lsp"])
        {nixpkgs = nixpkgs [];}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "aarch64-darwin";
    };
  };
in {
  donaldville = instances.donaldville;
  ac-donaldville = instances.donaldville;
}
