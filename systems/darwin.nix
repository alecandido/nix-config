{ self, darwin, home-manager, ... }@inputs:

let
  inherit (inputs.nixpkgs.lib) singleton;

  homeCommons = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };

  nixpkgs =((import ../overlays) inputs); 

  userInfo = { user }: rec {
    home-manager.users.${user} = import ../home;
    home-manager.sharedModules = singleton {
      nixpkgs = nixpkgs [];
    };
    home-manager.extraSpecialArgs = {
      inherit user;
      home = "/Users/${user}";
    };
    users.users.${user}.home = home-manager.extraSpecialArgs.home;
  };

in
{

  donaldville = darwin.lib.darwinSystem {
    modules = [
      ../etc/darwin
      home-manager.darwinModules.home-manager
      (homeCommons // (userInfo { user = "alessandro"; }))
    ] ++ singleton { nixpkgs =  nixpkgs [ ]; };
    system = "aarch64-darwin";
  };

}
