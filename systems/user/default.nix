{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) home-manager nixpkgs;
in {
  qrc = home-manager.lib.homeManagerConfiguration (
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
