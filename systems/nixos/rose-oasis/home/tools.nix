{lib, ...}: {
  programs.ghostty.settings.font-size = lib.mkForce 10;
  programs.kitty.font.size = lib.mkForce 12;
}
