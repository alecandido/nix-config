inputs: (let
  lib = import ./lib;
  args = {inherit inputs lib;};
in {
  darwin = (import ./darwin) args;
  user = (import ./user) args;
  nixos = (import ./nixos) args;
})
