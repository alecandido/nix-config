{pkgs, ...}: {
  imports = [
    ./formatters.nix
    ./linters.nix
    ./servers.nix
  ];

  home.packages = with pkgs; [
    tree-sitter
  ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  xdg.configFile."nvim".source = ./nvim;
}
