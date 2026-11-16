{
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.xpra
    (pkgs.callPackage "${inputs.self}/lib/remote-apps/xpra-wayland.nix" {})
  ];

  programs.ghostty.settings.font-size = lib.mkForce 10;
  programs.kitty.font.size = lib.mkForce 12;
}
