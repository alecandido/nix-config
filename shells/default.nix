{
  devenv.shells = {
    # a shell for this repo
    default = {
      scripts.format.exec = "nix fmt .";

      languages.nix.enable = true;

      git-hooks.hooks = {
        deadnix.enable = true;
        alejandra.enable = true;
      };
    };

    # make python available
    python = {
      languages.python.enable = true;
    };

    # make python available
    # with a related virtual environment, to install dependencies
    pyvenv = {
      languages.python = {
        enable = true;
        venv.enable = true;
      };
    };
  };
}
