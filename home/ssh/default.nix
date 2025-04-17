{
  pkgs,
  lib,
  ...
}: let
  isLinux = lib.strings.hasInfix "linux" pkgs.system;
in {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh_gssapi;
  };
  services.ssh-agent.enable = isLinux;
  home.packages = with pkgs; [sshfs];
}
