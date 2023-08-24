{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {inherit (tpkgs) scheme-basic latexmk amsmath collection-publishers collection-fontsrecommended collection-fontsextra collection-latexrecommended collection-latexextra collection-mathscience collection-pictures;};
  };
}
