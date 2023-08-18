{
  scripts.format.exec = "nix fmt .";

  languages.nix.enable = true;

  pre-commit.hooks = {
    deadnix.enable = true;
    markdownlint.enable = true;
    nixpkgs-fmt.enable = true;
  };
}
