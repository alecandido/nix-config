{ nixpkgs, ... }@inputs:

let
  system = nixpkgs.stdenv.system;
in
{
  formatter = {
    aarch64-darwin = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
  };
}
