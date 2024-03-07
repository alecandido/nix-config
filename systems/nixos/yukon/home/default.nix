let
  user = "alessandro";
in {
  inherit user;
  toggles = ["amenities" "neovim.lsp" "gnome" "server" "thunderbird"];
  extraHomeModules = [];
}
