{
  pkgs,
  toggles,
  ...
}: let
  lsp = builtins.elem "neovim.lsp" toggles;
  nufmt-in = pkgs.writeScriptBin "nufmt-in" ''
    #!/usr/bin/env -S nu --stdin
    nufmt --stdin $in | tail -n +2
  '';
in {
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
          rustfmt
          shfmt
          stylish-haskell
          stylua
          uncrustify
        ]
        ++ (lib.optionals (!stdenv.isDarwin) [nufmt nufmt-in])
        ++ (with nodePackages; [
          prettier
        ])
        ++ (with python311Packages; [
          docformatter
        ]))
    else [];

  xdg.configFile."uncrustify.cfg".text = "";
}
