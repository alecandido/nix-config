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

  "alessandro.candido@dalma" = home-manager.lib.homeManagerConfiguration (
    let
      user = "alessandro.candido";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      extraHomeModules = [];
    in {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs user extraHomeModules;
      };

      modules = [
        ../../home
        ./qrc
        lib.commonMods
      ];
    }
  );
}
