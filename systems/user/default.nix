{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) home-manager nixpkgs;
in {
  lxplus = home-manager.lib.homeManagerConfiguration (
    let
      user = "candidal";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      homeMods = lib.homeMods {
        inherit inputs;
        homeRoot = "/afs/cern.ch/user/c/candidal";
        config = {inherit user;};
      };
    in {
      inherit pkgs;

      modules = [
        ./lxplus
        homeMods
        lib.commonMods
      ];
    }
  );
}
