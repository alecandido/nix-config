{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [carapace]
    ++ (with pkgs.nushellPlugins; [
      # net
    ]);

  home.shell.enableNushellIntegration = true;

  programs.nushell = {
    enable = true;

    envFile.source = ./env.nu;
    configFile.source = ./config.nu;
    extraConfig = ''
      # plugin add ${pkgs.nushellPlugins.net}/bin/nu_plugin_net
      # plugin add <polars>
      # TODO:  ^^^^^^^^^^^^
    '';

    environmentVariables = config.home.sessionVariables;

    shellAliases = {
      la = "ls -a";
      ll = "ls -l";
      nv = "nvim";
      py = "python";
      ipy = "ipython";
      upgrade = "bash -ic upgrade";
    };
  };
}
