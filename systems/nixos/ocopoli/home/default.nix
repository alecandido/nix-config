{
  user = "alessandro";

  extraHomeModules = [
    ./tools.nix
    ({inputs, ...}: {
      imports = ["${inputs.self}/home/remote-apps.nix"];

      plan = {
        amenities.enable = true;
        dconf = {
          enable = true;
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
