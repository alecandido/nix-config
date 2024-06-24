{
  pkgs,
  toggles,
  ...
}: let
  lsp = builtins.elem "neovim.lsp" toggles;

  hmpkgs =
    if lsp
    then
      (with pkgs; [
        tree-sitter
      ])
    else [];
in {
  imports = [
    ./linters
    ./formatters
    ./servers.nix
  ];

  home.packages = hmpkgs;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  xdg.configFile."nvim".source = ./nvim;
}
