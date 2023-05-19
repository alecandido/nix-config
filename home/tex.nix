{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs) scheme-basic latexmk amsmath collection-fontsrecommended; };
  };
}
