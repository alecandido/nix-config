{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.plan.neovim;
in {
  config = mkIf (cfg.enable && cfg.lsp) {
    home.packages = with pkgs;
      [
        fortls
        golangci-lint-langserver
        gopls
        haskell-language-server
        ltex-ls
        lua-language-server
        metals
        nil
        ruff
        # rust-analyzer
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
        vscode-langservers-extracted
        yaml-language-server
      ])
      ++ (with pkgs.vscode-extensions; [
        dbaeumer.vscode-eslint
      ]);
  };
}
