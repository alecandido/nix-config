{
  programs.zsh = {
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };
    autocd = true;
  };
}
