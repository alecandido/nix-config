{ darwin
, home-manager
, ...
} @ inputs:
let
  inherit (inputs.nixpkgs.lib) singleton;

  nixpkgs = (import ../overlays_) inputs;

  homeMods = { user }:
    let
      extraSpecialArgs = {
        inherit user inputs;
        home = "/Users/${user}";
      };
    in
    {
      home-manager.users.${user} = import ../home;
      # Give `inputs` access to all home-manager modules,
      # together with `home` and `user` specification
      home-manager.extraSpecialArgs = extraSpecialArgs;
      # Set home
      users.users.${user}.home = extraSpecialArgs.home;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
in
{
  donaldville = darwin.lib.darwinSystem {
    modules =
      [
        ../etc/darwin
        home-manager.darwinModules.home-manager
        (homeMods { user = "alessandro"; })
      ]
      ++ singleton {
        nixpkgs = nixpkgs [ ];
      };

    # Give `inputs` access to all nix-darwin modules
    specialArgs = { inherit inputs; };
    system = "aarch64-darwin";
  };
}
