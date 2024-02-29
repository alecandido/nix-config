{ nixpkgs
, flake-utils
, ...
}:
let
  eachSystem = flake-utils.lib.eachDefaultSystem;
in
(eachSystem (system: {
  formatter = nixpkgs.legacyPackages.${system}.alejandra;
}))
