{ pkgs, ... }: {
  home.packages = with pkgs;
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
    ]);
}
