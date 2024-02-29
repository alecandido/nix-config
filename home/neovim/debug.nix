{
  pkgs,
  toggles,
  ...
}: let
  lsp = builtins.elem "neovim.lsp" toggles;
in {
  home.packages =
    if lsp
    then
      (with pkgs;
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
        ]))
    else [];
}
