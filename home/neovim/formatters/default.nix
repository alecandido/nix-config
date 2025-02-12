{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.plan.neovim;

  nufmt-in = pkgs.writeScriptBin "nufmt-in" ''
    #!/usr/bin/env -S nu --stdin
    nufmt --stdin $in | tail -n +2
  '';
in {
  config = mkIf (cfg.enable && cfg.lsp) {
    home.packages = with pkgs;
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
      ]);

    xdg.configFile."uncrustify.cfg".source = ./uncrustify.cfg;
  };
}
