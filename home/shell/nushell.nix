{pkgs, ...}: {
  home.packages = with pkgs; [carapace];

  programs.nushell = {
    enable = true;
    package = pkgs.nushellFull;

    envFile.source = ./env.nu;
    configFile.source = ./config.nu;

    shellAliases = {
      xs = "eza";
      xa = "ls -a";
      xl = "ls -l";
      nv = "nvim";
      py = "python";
      ipy = "ipython";
      upgrade = "bash -ic upgrade";
    };
  };
}
