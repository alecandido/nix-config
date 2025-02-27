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

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  environment = let
    shell = "${pkgs.nushell}/bin/nu";
  in {
    pathsToLink = ["/share/zsh"];
    shells = with pkgs; [nushell];
    shellAliases = {
      upgrade = ''
        darwin-rebuild switch --flake "$HOME/Projects/nix-config" --show-trace
      '';
    };
    variables = {SHELL = shell;};
  };

  # FIXME: attempt removing the following, reinstalling Nix on donaldville
  ids.gids.nixbld = 501;

  system.stateVersion = 6;
}
