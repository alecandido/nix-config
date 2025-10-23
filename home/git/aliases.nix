{
  programs.git.settings.alias = {
    st = "status";
    aa = "add .";
    au = "add -u";
    cm = "commit -m";
    csm = "commit -S -m";
    sw = "switch";
    br = "branch";
    co = "checkout";

    pop = "stash pop";
    drop = "stash drop";
    amend = "commit --amend";
    last = "show --stat";
    stat = "diff --stat";
    sup = "submodule update";

    branch-name = "rev-parse --abbrev-ref HEAD";
    branch-full-name = ''rev-parse --abbrev-ref --symbolic-full-name "@{u}"'';
    psuoc = "!git push -u origin $(git branch-name)";

    tree = "log --graph --decorate --pretty=oneline --abbrev-commit --all";

    aliases = "config --get-regexp ^alias";
  };
}
