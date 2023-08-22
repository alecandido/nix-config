{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    lua-language-server
  ] ++ (with pkgs.nodePackages; [
    typescript-language-server
    pyright
  ]) ++ (with pkgs.vscode-extensions; [ 
    dbaeumer.vscode-eslint 
  ]);
}
