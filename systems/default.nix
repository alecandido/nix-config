inputs: {
  darwin = (import ./darwin.nix) inputs;
  home = (import ./home).systems inputs;
  nixos = (import ./nixos) inputs;
}
