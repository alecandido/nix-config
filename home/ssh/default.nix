{pkgs, ...}: {
  programs.ssh = {
    enable = true;
  };

  home.file.".ssh/config".source = ./config;
  home.packages = with pkgs; [sshpass];
}
