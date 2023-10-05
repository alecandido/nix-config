{
  home.shellAliases = {
    ls = "exa";
    nv = "nvim";
    upgrade = ''
      darwin-rebuild switch --flake "$XDG_CONFIG_HOME/nixpkgs?submodules=1" --show-trace
    '';
    dev-flake = ''
      nix flake init --template github:cachix/devenv
    '';
    lxplus = ''
      sshpass -p $(rbw get CERN) ssh lxplus
    '';
  };
}
