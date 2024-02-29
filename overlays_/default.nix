inputs: extra: {
  config = {allowUnfree = true;};
  overlays = [(import ./devenv.nix inputs)] ++ extra;
}
