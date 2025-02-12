let
  user = "alessandro";
in {
  inherit user;
  toggles = ["amenities" "neovim.lsp"];
  extraHomeModules = [];

  plan.tex.enable = true;
}
