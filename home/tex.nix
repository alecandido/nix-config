{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.plan.tex;
in {
  options.plan.tex = {
    enable = mkEnableOption "tex";
  };

  config = {
    programs.texlive = mkIf cfg.enable {
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
  };
}
