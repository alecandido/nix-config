{pkgs, ...}: let
  devenvDisclaimer = ''
    devenv_dir=$PWD/.devenv
    if [ ! -d $devenv_dir ]; then
      echo "Creating devenv dir at '$devenv_dir'"
    fi
  '';
in {
  devenv.shells = {
    # a shell for this repo
    default = {
      scripts.format.exec = "nix fmt .";
      packages = with pkgs; [mistral-vibe];

      languages.nix.enable = true;

      git-hooks.hooks = {
        deadnix.enable = true;
        alejandra.enable = true;
      };
    };

    # make python available
    python = {
      enterShell = devenvDisclaimer;

      packages = with pkgs; [mistral-vibe];
      languages.python.enable = true;
    };

    # make python available
    # with a related virtual environment, to install dependencies
    pyvenv = {
      enterShell = devenvDisclaimer;

      languages.python = {
        enable = true;
        venv.enable = true;
      };
    };
  };
}
