{
  user = "alessandro";

  extraHomeModules = [
    {
      plan = {
        neovim = {
          enable = true;
          lsp = true;
        };
      };
    }
  ];
}
