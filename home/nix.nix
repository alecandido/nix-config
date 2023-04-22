{ pkgs, user, ... }:

{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    substituters = ["https://cache.nixos.org" "https://alecandido.cachix.org"];
    trusted-users = ["root" user];
    trusted-public-keys = [ 
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= alecandido.cachix.org-1:TgsrZYrtoZVpZ9nSlYBw2ylVFpHqLI1YnwhPTwjGdgM="
    ];
  };
}
