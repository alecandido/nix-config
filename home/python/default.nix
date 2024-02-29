{config, ...}: {
  xdg.configFile."ipython/profile_default/ipython_config.json".source = ./ipython.json;
  home.sessionVariables = {
    IPYTHONDIR = "${config.xdg.configHome}/ipython";
  };
}
