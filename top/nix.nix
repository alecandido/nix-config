{ nixpkgs, flake-utils, ... }@inputs:

let
  eachSystem = flake-utils.lib.eachDefaultSystem;
in
(eachSystem (system: {
  formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
}))
