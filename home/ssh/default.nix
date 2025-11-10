{
  pkgs,
  lib,
  ...
}: let
  isLinux = lib.strings.hasInfix "linux" pkgs.system;
in {
  imports = [
    ./config.nix
  ];
  programs.ssh = {
    enable = true;
    package = pkgs.openssh_gssapi;
    enableDefaultConfig = false;
  };
  services.ssh-agent.enable = isLinux;
  home.packages = with pkgs; [sshfs];
}
