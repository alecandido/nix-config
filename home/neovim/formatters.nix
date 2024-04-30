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
          nufmt
          nufmt-in
          pgformatter
          rustfmt
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
    else [];

  xdg.configFile."uncrustify.cfg".text = "";
}
