{ nixpkgs, ... }@inputs:

{
  formatter = {
    aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
  };
}
