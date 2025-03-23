{
  pkgs,
  config,
  ...
}: let
  home = config.home;
  xdg = config.xdg;
in {
  home.packages = with pkgs; [universal-ctags];

  programs.git.extraConfig = {
    user = {
      signingKey = "${home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    commit.gpgSign = true;
    tag.gpgSign = true;
    gpg.format = "ssh";
    core = {
      editor = "nvim";
      quotepath = false;
    };
    web.browser = "firefox";
    status.submoduleSummary = true;
    submodule.recurse = true;
    init = {
      defaultBranch = "main";
      templateDir = "${xdg.configHome}/git/template";
    };
    # commit ops
    pull.rebase = "interactive";
    fetch = {
      prune = true;
      pruneTags = true;
      all = true;
    };
    push = {
      autoSetupRemote = true;
      followTags = true;
    };
    merge.log = true;
    diff = {
      renames = "copies";
      tool = "vimdiff";
      submodules = "log";
      # --- in case of default diff
      algorithm = "histogram";
      colorMoved = "plain";
      mnemonicPrefix = true;
    };
    rerere = {
      enabled = true;
      autoupdate = true;
    };
    # ui
    column.ui = "auto nodense";
    branch.sort = "-committerdate";
    tag.sort = "version:refname";
    color = {
      status = {
        changed = "yellow";
      };
      branch = {
        current = "yellow bold";
        local = "green";
        remote = "blue";
        upstream = "blue bold";
        plain = 7;
      };
    };
  };

  xdg.configFile."git/template".source = ./template;
}
