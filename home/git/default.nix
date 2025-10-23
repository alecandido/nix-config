{
  imports = [./aliases.nix ./config.nix];

  programs.git = {
    enable = true;

    settings.user = {
      name = "Alessandro Candido";
      email = "candido.ale@gmail.com";
    };

    ignores = [
      ".DS_Store"
      ".direnv"
      "/tags"
      ".gdb_history"
      ".pnpm-debug.log"
    ];
  };

  # programs.git.delta = {
  #   enable = true;
  #   options = {
  #     features = "decorations";
  #     side-by-side = true;
  #   };
  # };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.background = "dark";
  };
}
