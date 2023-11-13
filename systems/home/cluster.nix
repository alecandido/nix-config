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
      toggles = [];
    in
    {
      inherit pkgs;
      modules = [
        # ./home.nix
        ((import ../../home) { inherit user; })
        ({ lib, ...}: {
          _module.args = { inherit user home inputs toggles; };
	  programs.zsh.enable = true;
          nix.package = pkgs.nix;
          home.homeDirectory = home;
          home.shellAliases.upgrade = lib.mkForce ''
            home-manager switch --flake "$XDG_CONFIG_HOME/nixpkgs#lxplus" --show-trace
          '';
        })
        { nixpkgs = nixpkgsOv [ ]; }
      ];
    }
  );
}
