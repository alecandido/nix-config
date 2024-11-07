let
  user = "alessandro";
in {
  inherit user;
  toggles = ["amenities" "neovim.lsp" "gnome" "server"];
  extraHomeModules = [./www.nix];
}
