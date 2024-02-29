{pkgs, ...}: {
  home.packages = with pkgs; [
    tldr
    cheat
  ];

  xdg.configFile."cheat/conf.yml".source = ./conf.yml;
}
