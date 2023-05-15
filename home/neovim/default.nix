{ ... }:

{
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  xdg.configFile."nvim/lua/custom".source = ./custom;
}
