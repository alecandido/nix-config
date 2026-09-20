{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    lib = nixpkgs.lib;

    supportedSystems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    # Everything nvim needs on the PATH, as a plain list.
    # Shared by devenv and the installed home configuration.
    servers = pkgs:
      import ./nix/servers.nix {
        inherit pkgs;
        inherit (pkgs) lib;
      };

    # Home-manager module: installs neovim + this configuration + servers.
    # Expects the `plan.neovim` options (defined here) so that the
    # consuming system can toggle `enable` / `lsp`.
    neovimHomeModule = {
      pkgs,
      config,
      lib,
      ...
    }: let
      cfg = config.plan.neovim;

      # nvim.yml, .luarc.json, ftdetect/ and friends must NOT end up
      # inside $XDG_CONFIG_HOME/nvim (they belong to the repo checkout,
      # not to the running configuration).
      nvimConfig = pkgs.runCommand "nvim-config" {} ''
        mkdir -p $out
        cp -r ${/.} \
          $out/
        rm -rf \
          $out/.envrc \
          $out/.gitignore \
          $out/.luarc.json \
          $out/.devenv \
          $out/.devenv* \
          $out/.direnv \
          $out/README.md \
          $out/nvim.yml \
          $out/flake.nix \
          $out/flake.lock \
          $out/nix \
          $out/devenv.nix \
          $out/devenv.yaml \
          $out/devenv.lock
        find $out -name '.gitkeep' -delete
      '';
    in {
      options.plan.neovim = {
        enable = lib.mkEnableOption "neovim";
        lsp = lib.mkEnableOption "neovim lsp";
      };

      config = lib.mkIf cfg.enable {
        home.packages =
          (
            # requested by lazy checkhealth
            with pkgs.lua51Packages; [
              lua
              luarocks
            ]
          )
          ++ lib.optional cfg.lsp pkgs.tree-sitter
          ++ lib.optionals cfg.lsp (servers pkgs);

        programs.neovim.enable = true;
        programs.neovim.defaultEditor = true;
        programs.neovim.vimdiffAlias = true;

        xdg.configFile."nvim".source = nvimConfig;
      };
    };
  in {
    packages = lib.genAttrs supportedSystems (
      system: let
        pkgs = mkPkgs system;
      in rec {
        default = nvim;
        nvim = pkgs.neovim;
        nvim-servers = pkgs.buildEnv {
          name = "nvim-servers";
          paths = servers pkgs;
        };
      }
    );

    homeManagerModules.default = neovimHomeModule;
    homeManagerModules.neovim = neovimHomeModule;
  };
}
