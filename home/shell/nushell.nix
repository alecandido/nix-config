{
  pkgs,
  config,
  lib,
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
      # FIX: workaround for browser issues
      # https://github.com/bandithedoge/nixpkgs-firefox-darwin/issues/14
      # https://github.com/nix-community/home-manager/issues/3323
      # https://github.com/nix-community/home-manager/issues/5717
      browser = lib.mkIf pkgs.stdenv.isDarwin ''bash -c "MOZ_LEGACY_PROFILES=1 nohup $BROWSER >/dev/null 2>&1 &"'';
    };
  };

  # TODO: explicitly activate until the zoxide nushell init patch will be available
  xdg.cacheFile."zoxide/init.nu".source = ./zoxide-init.nu;
}
