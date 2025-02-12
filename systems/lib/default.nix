{
  homeMods = {
    config,
    homeRoot,
    inputs,
  }: let
    user = config.user;
    home = config.home;
    extraHomeModules = config.extraHomeModules ++ [./home-modules];
  in {
    home-manager.users.${user} = import homeRoot;
    # Give `inputs` access to all home-manager modules, together with `home` and `user`
    # specification
    home-manager.extraSpecialArgs = {
      inherit inputs extraHomeModules;
      inherit (config) user home;
    };

    # Set home
    users.users.${user}.home = home;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };

  commonMods = {nixpkgs.config.allowUnfree = true;};
}
