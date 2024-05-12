{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [carapace]
    ++ (with pkgs.nushellPlugins; [
      net
    ]);

  programs.nushell = {
    enable = true;
    package = pkgs.nushellFull;

    envFile.source = ./env.nu;
    configFile.source = ./config.nu;
    extraConfig = ''
      register ${pkgs.nushellPlugins.net}/bin/nu_plugin_net
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
