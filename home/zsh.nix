{ pkgs, ... }:

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
    enableAutosuggestions = true;
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
    '';
  };
}
