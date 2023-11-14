{ pkgs
, config
, ...
}:
let
  home = config.home;
  xdg = config.xdg;
in
{
  home.packages = with pkgs; [ universal-ctags ];

  programs.git.extraConfig = {
    user = {
      signingKey = "${home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    core = {
      editor = "nvim";
      quotepath = false;
    };
    web.browser = "firefox";
    pull.rebase = "interactive";
    merge.log = true;
    init = {
      defaultBranch = "main";
      templateDir = "${xdg.configHome}/git/template";
    };
    column.ui = "auto nodense";
    gpg.format = "ssh";
    diff = {
      renames = "copies";
      tool = "vimdiff";
    };
    rerere = {
      enabled = true;
      autoupdate = true;
    };
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
