{ pkgs
, toggles
, ...
}:
let
  lsp = builtins.elem "neovim.lsp" toggles;

  hmpkgs =
    if lsp
    then
      (with pkgs; [
        tree-sitter
      ])
    else [ ];
in
{
  imports = [
    ./linters
    ./formatters.nix
    ./servers.nix
  ];

  home.packages = hmpkgs;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "AleCandido";
    repo = "nvim";
    rev = "main";
    hash = "sha256-KHcqxlr//oSJH4TwlTxyh+xgtE7UBXEWyjRsCvw1VgI=";
  };
}
