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
        alejandra
        black
        fnlfmt
        isort
        ktlint
        pgformatter
        shfmt
        stylish-haskell
        stylua
        uncrustify
      ]
      ++ (with pkgs.nodePackages; [
        prettier
      ])
      ++ (with pkgs.python311Packages; [
        docformatter
      ]))
    else [ ];
}
