{
  pkgs,
  lib,
  ...
}: let
  servers = import ./nix/servers.nix {
    inherit pkgs lib;
  };
in {
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
