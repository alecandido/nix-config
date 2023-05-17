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
  };
}
