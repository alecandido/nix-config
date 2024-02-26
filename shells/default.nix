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
    devenvDisclaimer = ''
      devenv_dir=$PWD/.devenv
      if [ ! -d $devenv_dir ]; then
        echo "Creating devenv dir at '$devenv_dir'"
      fi
    '';
  in
  {
    # a shell for this repo
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

    # make python available
    python = devenv.lib.mkShell {
      inherit inputs pkgs;

      modules = [
        {
          enterShell = devenvDisclaimer;

          languages.python.enable = true;
        }
      ];
    };

    # make python available
    # with a related virtual environment, to install dependencies
    pyvenv = devenv.lib.mkShell {
      inherit inputs pkgs;

      modules = [
        {
          enterShell = devenvDisclaimer;

          languages.python = {
            enable = true;
            venv.enable = true;
          };
        }
      ];
    };
  })
