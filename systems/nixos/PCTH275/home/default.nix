{
  user = "alessandro";

  extraHomeModules = [
    ./tools.nix
    {
      plan = {
        amenities.enable = true;
        dconf = {
          enable = true;
          server = true;
        };
        neovim = {
          enable = true;
          lsp = true;
        };
        tex.enable = true;
      };
    }
  ];
}
