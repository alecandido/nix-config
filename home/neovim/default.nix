{ pkgs
, toggles
, ...
}:
let
  lsp = builtins.elem "neovim.lsp" toggles;
  submodules = builtins.elem "submodules" toggles;

  imports =
    if lsp
    then [
      ./linters
      ./formatters.nix
      ./servers.nix
    ]
    else [ ];

  hmpkgs =
    if lsp
    then
      (with pkgs; [
        tree-sitter
      ])
    else [ ];
in
{
  inherit imports;

  home.packages = hmpkgs;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  xdg.configFile."nvim".source =
    if submodules
    then ./nvim
    else null;
}
