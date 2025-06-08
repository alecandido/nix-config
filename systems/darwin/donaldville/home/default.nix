{
  user = "alessandro";

  extraHomeModules = [
    {
      plan = {
        amenities.enable = true;
        neovim = {
          enable = true;
          lsp = true;
        };
        # tex.enable = true;
      };
    }
  ];
}
