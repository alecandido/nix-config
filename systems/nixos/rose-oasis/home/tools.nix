{lib, ...}: {
  programs.ghostty.settings.font-size = lib.mkForce 14;
  programs.kitty.font.size = lib.mkForce 12;
}
