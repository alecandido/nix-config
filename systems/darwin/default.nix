{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin home-manager self;

  mkDarwin = name: (let
    config = import "${path}/home";
    user = config.user;
    path = ./. + ("/" + name);
    homeMods = lib.homeMods {
      inherit inputs;
      homeRoot = "${self}/home";
      config = config // {home = "/Users/${user}";};
    };
  in
    darwin.lib.darwinSystem {
      modules = [
        {
          networking.hostName = name;
          nix.settings.trusted-users = [user];
          # FIX: required to support determinate Nix distribution
          # https://github.com/LnL7/nix-darwin/issues/1349
          # https://github.com/LnL7/nix-darwin/pull/1367
          environment.etc."nix/nix.custom.conf" = {
            enable = true;
            text = ''
              extra-trusted-substituters = https://devenv.cachix.org
              extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
            '';
          };
        }
        "${self}/etc/darwin"
        path
        home-manager.darwinModules.home-manager
        homeMods
        inputs.agenix.darwinModules.default
        lib.commonMods
        {nixpkgs.overlays = [inputs.nixpkgs-firefox-darwin.overlay];}
      ];

      # Give `inputs` access to all nix-darwin modules
      specialArgs = {inherit inputs;};
      system = "aarch64-darwin";
    });

  instances = {
    donaldville = mkDarwin "donaldville";
  };
in {
  donaldville = instances.donaldville;
  ac-donaldville = instances.donaldville;
}
