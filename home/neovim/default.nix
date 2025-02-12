{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.plan.neovim;
in {
  imports = [
    ./linters
    ./formatters
    ./servers.nix
  ];

  options.plan.neovim = {
    enable = mkEnableOption "neovim";
    lsp = mkEnableOption "neovim lsp";
  };

  config = mkIf cfg.enable {
    home.packages = mkIf cfg.lsp (with pkgs; [tree-sitter]);

    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;
    programs.neovim.vimdiffAlias = true;

    xdg.configFile."nvim".source = ./nvim;
  };
}
