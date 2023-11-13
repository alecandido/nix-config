inputs: {
  darwin = (import ./darwin.nix) inputs;
  home = (import ./home).systems inputs;
}
