{
  user = "alessandro";

  extraHomeModules = [
    ./tools.nix
    ./niri.nix
    ({config, ...}: {
      plan = {
        amenities.enable = true;
        dconf = {
          enable = !config.plan.niri.enable;
          server = true;
        };
        neovim = {
          enable = true;
          lsp = true;
        };
        tex.enable = true;
      };
    })
  ];
}
