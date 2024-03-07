{inputs, ...}: let
  inherit (inputs) home-manager nixpkgs self;
  nixpkgsOv = (import "${self}/overlays_}") inputs;
in {
  lxplus = home-manager.lib.homeManagerConfiguration (
    let
      user = "candidal";
      home = "/afs/cern.ch/user/c/candidal";
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      toggles = [];
    in {
      inherit pkgs;
      modules = [
        # ./home.nix
        ((import ../../home) {inherit user;})
        ({lib, ...}: {
          _module.args = {inherit user home inputs toggles;};
          programs.zsh.enable = true;
          nix.package = pkgs.nix;
          home.homeDirectory = home;
          home.sessionVariables = {
            SHELL = "/bin/zsh";
          };
          home.shellAliases.upgrade = lib.mkForce ''
            home-manager switch --flake "$XDG_CONFIG_HOME/nixpkgs#lxplus" --show-trace
          '';
          home.shellAliases.upgrade-hack = ''
            home-manager switch --flake .config/home-manager && home-manager switch --flake .config/nixpkgs#lxplus --show-trace
          '';
        })
        {nixpkgs = nixpkgsOv [];}
      ];
    }
  );
}
