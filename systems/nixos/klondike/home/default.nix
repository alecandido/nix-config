let
  user = "alessandro";
in {
  inherit user;
  toggles = ["amenities" "tex" "neovim.lsp" "server"];
  extraHomeModules = [];
}
