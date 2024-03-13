{
  pkgs,
  lib,
  ...
}: {
  toggles = [];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    tldr
    gh
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "/bin/zsh";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.neovim.enable = true;
  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
      default_layout = "compact";
    };
  };
  programs.zsh = {
    enable = true;
    shellAliases = {
      nv = "nvim";
      ll = "ls -l";
      la = "ls -a";
      home-shell = "nix shell nixpkgs#home-manager";
    };
  };
  programs.ssh.enable = true;
  xdg.enable = true;
  home.file.".ssh/config".text = "";
  nix.settings = {experimental-features = ["nix-command" "flakes"];};

  targets.genericLinux.enable = true;
  home.sessionPath = ["$HOME/.nix-profile/etc/profile.d/nix.sh"];

  nix.package = pkgs.nix;
  home.shellAliases.upgrade = lib.mkForce ''
    home-manager switch --flake "$XDG_CONFIG_HOME/nixpkgs#lxplus" --show-trace
  '';
  home.shellAliases.upgrade-hack = ''
    home-manager switch --flake .config/home-manager && home-manager switch --flake .config/nixpkgs#lxplus --show-trace
  '';
}
