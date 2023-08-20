{ pkgs, ... }:

{
  home.packages = with pkgs; [ zsh-fzf-tab ];

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
