{
  lib = import ./lib.nix;
  systems = inputs: (import ./cluster.nix) inputs;
}
