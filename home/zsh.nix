{ pkgs
, config
, ...
}:
let
  home = config.home;
in
{
  home.packages = with pkgs; [
    zsh-fzf-tab
    zsh-vi-mode
    zsh-autopair
    zsh-system-clipboard
    zsh-completions
    nix-zsh-completions
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
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
