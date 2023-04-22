{ self, ... }@inputs:

{
  darwin = (import ./darwin.nix) inputs;
}
