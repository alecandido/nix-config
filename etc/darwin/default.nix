{pkgs, ...}: {
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
        sudo darwin-rebuild switch --flake "$HOME/Projects/nix-config" --show-trace
      '';
    };
    variables = {SHELL = shell;};
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;
}
