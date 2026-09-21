{ pkgs, ... }:
let
  devenvConfig = {
    version = 1;
    shell.prompt_prefix = false;
    tui.statusline.enabled = false;
  };
in
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Useful nix related tools
  home.packages = with pkgs; [
    cachix
  ];

  programs.devenv = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Devenv: disable prompt prefix and statusline
  # https://devenv.sh/blog/2026/09/07/devenv-23-portless-and-tui-configuration/#your-terminal-your-configuration
  xdg.configFile."devenv/config.yaml".text = builtins.toJSON devenvConfig;
}
