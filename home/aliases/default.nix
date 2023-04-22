{
  home.shellAliases = {
    ls = "exa";
    upgrade =
      "darwin-rebuild switch --flake $XDG_CONFIG_HOME/nixpkgs --show-trace";
  };
}
