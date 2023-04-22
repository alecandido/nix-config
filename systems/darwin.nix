{ self, darwin, home-manager, ... }@inputs:

let
  homeCommons = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
  userInfo = { user }: rec {
    home-manager.users.${user} = import ../home;
    home-manager.extraSpecialArgs = {
      inherit inputs;
      user = user;
      home = "/Users/${user}";
    };
    users.users.${user}.home = home-manager.extraSpecialArgs.home;
  };
in {
  donaldville = darwin.lib.darwinSystem {
    modules = [
      ../configs
      home-manager.darwinModules.home-manager
      (homeCommons // (userInfo { user = "alessandro"; }))
    ];
    system = "aarch64-darwin";
  };
}
