{toggles, ...}: let
  enable = builtins.elem "tex" toggles;
in
  if enable
  then {
    programs.texlive = {
      enable = true;
      extraPackages = tpkgs: {
        inherit
          (tpkgs)
          scheme-basic
          latexmk
          amsmath
          lacheck
          collection-publishers
          collection-fontsrecommended
          collection-fontsextra
          collection-latexrecommended
          collection-latexextra
          collection-mathscience
          collection-pictures
          ;
      };
    };
  }
  else {}
