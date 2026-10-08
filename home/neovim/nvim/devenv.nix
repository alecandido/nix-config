{
  pkgs,
  lib,
  config,
  ...
}: let
  servers = import ./nix/servers.nix {
    inherit pkgs lib;
  };
in {
  env.NVIM_APPNAME = "nvim-nix-config";

  scripts."tree-sitter".exec = ''
    args=()
    for arg in "$@"; do
      if [ "$arg" != "--no-bindings" ]; then
        args+=("$arg")
      fi
    done
    exec ${pkgs.tree-sitter}/bin/tree-sitter "''${args[@]}"
  '';

  enterShell = ''
    XDG_CONF="''${XDG_CONFIG_HOME:-$HOME/.config}"
    mkdir -p "$XDG_CONF"
    ln -sfn "${config.env.DEVENV_ROOT}" "$XDG_CONF/nvim-nix-config"
  '';

  packages =
    (with pkgs; [
      neovim
      tree-sitter
    ])
    ++ (with pkgs.lua51Packages; [
      lua
      luarocks
    ])
    ++ servers;
}
