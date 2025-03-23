{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = {
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              languages.lua.enable = true;

              packages = with pkgs; [selene stylua];

              pre-commit.hooks = {
                selene = {
                  enable = true;
                  name = "selene";
                  description = "Lint lua code with selene";
                  files = "\.lua$";
                  entry = "${pkgs.selene}/bin/selene";
                };
                stylua = {
                  enable = true;
                  name = "stylua";
                  description = "Format lua code with stylua";
                  files = "\.lua$";
                  entry = "${pkgs.stylua}/bin/stylua";
                };
              };
            }
          ];
        };
      });
  };
}
