{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.plan.neovim;
in {
  config = mkIf (cfg.enable && cfg.lsp) {
    xdg.configFile."uncrustify.cfg".source = ./uncrustify.cfg;
  };
}
