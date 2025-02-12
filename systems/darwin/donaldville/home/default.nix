let
  user = "alessandro";
in {
  inherit user;
  toggles = ["neovim.lsp"];
  extraHomeModules = [
    {
      plan = {
        amenities.enable = true;
        tex.enable = true;
      };
    }
  ];
}
