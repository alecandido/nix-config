{ devenv, ... }@inputs:

extra:

{
  config = { allowUnfree = true; };
  overlays = [ ] ++ extra;
}
