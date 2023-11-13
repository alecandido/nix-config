{
  homeMods =
    { inputs
    , user
    , home
    ,
    }:
    let
      extraSpecialArgs = {
        inherit user inputs home;
      };
    in
    {
      home-manager.users.${user} = import ../../home;
      # Give `inputs` access to all home-manager modules,
      # together with `home` and `user` specification
      home-manager.extraSpecialArgs = extraSpecialArgs;
      # Set home
      users.users.${user}.home = extraSpecialArgs.home;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
}
