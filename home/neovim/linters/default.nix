{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.plan.neovim;
in {
  config = mkIf (cfg.enable && cfg.lsp) {
    xdg.configFile."ltex".source = ./ltex;
    xdg.configFile."yamllint".source = ./yamllint;
  };
}
