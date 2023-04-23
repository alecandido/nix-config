{
  imports = [ ./aliases.nix ./delta.nix ];

  programs.git = {
    enable = true;

    userName = "Alessandro Candido";
    userEmail = "candido.ale@gmail.com";

    ignores = [ ".DS_Store" ".venv-this" ];
  };
}
