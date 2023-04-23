{ config, ...}:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  programs.neovim.enable = true;

  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "${nixConfigDirectory}/configs/nvim/lua";

  # Load the `init` module from the above configs
  # programs.neovim.extraConfig = "lua require('init')";
}
