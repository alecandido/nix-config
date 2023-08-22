{ config, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  programs.git.extraConfig = {
    core = {
      editor = "nvim";
      quotepath = false;
    };
    web.browser = "firefox";
    pull.rebase = "interactive";
    merge.log = true;
    init = {
      defaultBranch = "main";
      templateDir = "$XDG_CONFIG_HOME/git/template";
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
    url = {
      "ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
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
