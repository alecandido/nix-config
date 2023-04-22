{ config, pkgs, lib, ... }:

{
  programs.neovim.enable = true;

  # Put neovim configuration located in this repository into place in a way that edits to the
  # configuration don't require rebuilding the `home-manager` environment to take effect.
  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "/Users/alessandro/.config/nixpkgs/configs/nvim/lua";

  # Load the `init` module from the above configs
  programs.neovim.extraConfig = "lua require('init')";
}
