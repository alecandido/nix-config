{
  pkgs,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    forwardAgent = true;
  };

  services.ssh-agent.enable = lib.strings.hasInfix "linux" pkgs.system;

  home.file.".ssh/config".source = ./config;
  home.packages = with pkgs; [sshfs];
}
