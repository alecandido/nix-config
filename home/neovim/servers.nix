{ pkgs
, toggles
, ...
}:
let
  lsp = builtins.elem "neovim.lsp" toggles;
in
{
  home.packages =
    if lsp
    then
      (with pkgs;
      [
        fortls
        golangci-lint-langserver
        gopls
        haskell-language-server
        ltex-ls
        lua-language-server
        metals
        nil
        rust-analyzer
        # sqls
        taplo
        texlab
        # verible
        vhdl-ls
      ]
      ++ (with pkgs.nodePackages; [
        bash-language-server
        pyright
        svelte-language-server
        typescript-language-server
        vscode-css-languageserver-bin
        yaml-language-server
      ])
      ++ (with pkgs.vscode-extensions; [
        dbaeumer.vscode-eslint
      ])
      ++ (with pkgs.python311Packages; [
        # ruff-lsp
      ]))
    else [ ];
}
