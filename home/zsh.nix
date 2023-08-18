{ pkgs, ... }:

{
  home.packages = with pkgs; [ zsh-fzf-tab ];

  programs.zsh = {
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
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
