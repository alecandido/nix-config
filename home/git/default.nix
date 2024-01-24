{
  imports = [ ./aliases.nix ./config.nix ];

  programs.git = {
    enable = true;

    userName = "Alessandro Candido";
    userEmail = "candido.ale@gmail.com";

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

  programs.git.difftastic = {
    enable = true;
    background = "dark";
  };
}
