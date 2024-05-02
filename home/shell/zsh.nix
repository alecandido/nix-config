{
  pkgs,
  config,
  ...
}: let
  home = config.home;
  xdg = config.xdg;
in {
  home.packages = with pkgs; [
    zsh-vi-mode
    zsh-autopair
    zsh-system-clipboard
    zsh-completions
    nix-zsh-completions
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch = {
      enable = true;
    };
    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };
    autocd = true;
    initExtra = ''
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt pushdminus

      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      develop () {
        nix develop ${xdg.configHome}/nixpkgs#$1 --impure -c $SHELL
      }
      flake-init () {
        nix flake init --template github:alecandido/flakes
      };
      kcern () {
        echo $(rbw get CERN) | kinit candidal@CERN.CH
      }
    '';
    envExtra = ''
      export KEYTIMEOUT=1
    '';
    dirHashes = {
      vid = "${home.homeDirectory}/Videos";
      dl = "${home.homeDirectory}/Downloads";
    };
  };
}
