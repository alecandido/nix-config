{ pkgs, ... }: 
let 
  lsp = builtins.elem "neovim.lsp" []; #toggles;

  imports = (if lsp
	  then [
	   ./linters
	   ./formatters.nix
	   ./servers.nix
	  ] else []);
  
  hpkgs = (if lsp then (with pkgs; [
    tree-sitter
  ]) else []);
in {
  inherit imports;

  home.packages = hpkgs;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimdiffAlias = true;

  # xdg.configFile."nvim".source = ./nvim;
}
