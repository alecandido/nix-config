let
  user = "alessandro";
in {
  inherit user;
  toggles = ["neovim.lsp"];
  extraHomeModules = [
    {
      plan = {
        amenities.enable = true;
        neovim = {
          enable = true;
          lsp = true;
        };
        tex.enable = true;
      };
    }
  ];
}
