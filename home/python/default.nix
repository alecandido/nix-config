{ config, ... }: {
  xdg.configFile."ipython/ipython_config.json".source = ./ipython.json;
  home.sessionVariables = {
    IPYTHONDIR = "${config.xdg.configHome}/ipython";
  };
}
