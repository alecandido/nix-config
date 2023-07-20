{ devenv, ... }@inputs:

extra:

{
  config = { allowUnfree = true; };
  overlays = [ ./devenv.nix ] ++ extra;
}
