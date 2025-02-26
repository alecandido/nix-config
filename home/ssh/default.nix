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
    forwardAgent = true;
  };

  services.ssh-agent.enable = isLinux;

  home.file.".ssh/config".source = ./config;
  home.packages = with pkgs; [sshfs];
}
