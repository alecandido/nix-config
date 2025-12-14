{
  inputs,
  pkgs,
  lib,
  ...
}: {
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;

    gc = lib.mkIf (!pkgs.stdenv.isDarwin) {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://alecandido.cachix.org"
      ];
      trusted-users = ["root"];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        "alecandido.cachix.org-1:TgsrZYrtoZVpZ9nSlYBw2ylVFpHqLI1YnwhPTwjGdgM="
      ];
    };
  };
}
