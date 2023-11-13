{ home-manager
, nixpkgs
, ...
} @ inputs:
let
  nixpkgsOv = (import ../../overlays_) inputs;
in
{
  lxplus = home-manager.lib.homeManagerConfiguration (
    let
      user = "candidal";
      home = "/afs/cern.ch/user/c/candidal";
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
    {
      inherit pkgs;
      modules = [
        ./home.nix
        # ((import ../../home) { inherit user; })
        {
          nix.package = pkgs.nix;
          home.homeDirectory = home;
          home.shellAliases.upgrade = ''
            home-manager switch --flake "$XDG_CONFIG_HOME/nixpkgs#lxplus" --show-trace
          '';
          _module.args = { inherit user home inputs; };
        }
        { nixpkgs = nixpkgsOv [ ]; }
      ];
    }
  );
}
