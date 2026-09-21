{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {self, nixpkgs, ...}: let
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

      # Map only the subdirectories needed at runtime into $XDG_CONFIG_HOME/nvim.
      # We do NOT symlink the whole directory because programs.neovim also
      # writes $XDG_CONFIG_HOME/nvim/init.lua, and home-manager cannot install
      # a file inside a path that is already a symlink to the nix store
      # (outside $HOME).  Instead we expose each subdirectory individually and
      # feed init.lua via programs.neovim.extraLuaConfig.
      src = self;
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
        # Inline init.lua so that programs.neovim can write
        # $XDG_CONFIG_HOME/nvim/init.lua without conflicting with a
        # whole-directory xdg.configFile."nvim" symlink.
        programs.neovim.extraLuaConfig = builtins.readFile (src + "/init.lua");

        # Map each runtime subdirectory individually.
        xdg.configFile."nvim/lua".source = src + "/lua";
        xdg.configFile."nvim/ftdetect".source = src + "/ftdetect";
        xdg.configFile."nvim/ftplugin".source = src + "/ftplugin";

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
