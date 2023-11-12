{
  # TODO: it has been required to make it work the first time, now moved to home/nix.nix
  #nix = {
  #  package = pkgs.nixFlakes;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  #};

  imports = [ ../fonts.nix ../keyboard.nix ../nix.nix ];

  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  environment.pathsToLink = [ "/share/zsh" ];

  system.stateVersion = 4;
}
