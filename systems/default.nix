inputs: (let
  lib = import ./lib;
  args = {inherit inputs lib;};
in {
  darwin = (import ./darwin.nix) args;
  home = (import ./home) args;
  nixos = (import ./nixos) args;
})
