{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
  };

  home.file.".ssh/config".source = ./config;
  home.packages = with pkgs; [ sshpass ];
}
