{pkgs, ...}: {
  # TODO: it has been required to make it work the first time, now moved to home/nix.nix
  #nix = {
  #  package = pkgs.nixFlakes;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  #};

  imports = [../nix.nix];

  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  environment = let
    shell = "${pkgs.nushell}/bin/nu";
  in {
    pathsToLink = ["/share/zsh"];
    # the following is only used by the tmux module, but it's not possible to set nu as
    # login shell unless it is managed by Nix, since the package might change, and I'd
    # not be able to login any longer to change the shell
    loginShell = shell + " -l";
    shells = with pkgs; [nushell];
    shellAliases = {
      upgrade = ''
        darwin-rebuild switch --flake "$HOME/Projects/nixpkgs" --show-trace
      '';
    };
    variables = {SHELL = shell;};
  };

  system.stateVersion = 4;
}
