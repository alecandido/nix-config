{
  imports = [
    ./nushell.nix
    ./zsh.nix
  ];

  home.shellAliases = {
    ls = "eza";
    la = "ls -a";
    ll = "ls -l";
    nv = "nvim";
    py = "python";
    ipy = "ipython";
    rename = "rnr";
  };
}
