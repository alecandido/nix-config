{ pkgs, ... }: {
  home.packages = with pkgs; [
    tldr
    cheat
  ];
}
