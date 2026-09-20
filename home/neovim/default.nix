# The neovim configuration itself (lua files, plugins, LSP setup) is a
# standalone flake at ./nvim (see home/neovim/nvim/flake.nix).
# It can be developed on its own (`devenv shell` / direnv in ./nvim)
# without rebuilding this whole system; it is also consumed here, so the
# installed system gets neovim + config + LSP servers.
{inputs, ...}: {
  imports = [
    inputs.nvim.homeManagerModules.default
    ./linters
    ./formatters
  ];
}
