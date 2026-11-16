{
  user = "alessandro";

  extraHomeModules = [
    ({inputs, ...}: {
      imports = ["${inputs.self}/home/remote-apps.nix"];

      plan = {
        amenities.enable = true;
        neovim = {
          enable = true;
          lsp = true;
        };
        # tex.enable = true;
      };
    })
  ];
}
