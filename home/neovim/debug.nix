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
        delve
      ]
      ++ (with pkgs.vscode-extensions; [
        firefox-devtools.vscode-firefox-debug
        ms-vscode.cpptools
      ])
      ++ (with pkgs.python311Packages; [
        debugpy
      ])
      ++ (with pkgs.haskellPackages; [
        haskell-debug-adapter
      ]);
  };
}
