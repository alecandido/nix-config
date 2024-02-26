{ nixpkgs
, devenv
, systems
, ...
} @ inputs:
let
  forEachSystem = nixpkgs.lib.genAttrs (import systems);
in
forEachSystem
  (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    default = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        {
          scripts.format.exec = "nix fmt .";

          languages.nix.enable = true;

          pre-commit.hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
          };
        }
      ];
    };
  })
