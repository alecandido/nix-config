{lib, ...}: {
  programs.kitty.font.size = lib.mkForce 12;
  programs.ghostty.settings = {
    font-size = lib.mkForce 15;
    fullscreen = true;
    font-family = lib.mkForce "FiraCode Nerd Font";
    theme = lib.mkForce "dark:Catppuccin Mocha,light:Alabaster";
  };
}
