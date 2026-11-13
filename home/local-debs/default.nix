{
  lib,
  pkgs,
  ...
}: {
  imports = [../../lib/local-debs];

  programs.localDebInstaller.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
}
