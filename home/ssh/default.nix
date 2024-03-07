{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    forwardAgent = true;
  };

  home.file.".ssh/config".source = ./config;
  home.packages = with pkgs; [sshfs];
}
