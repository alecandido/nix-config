{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  devenv = inputs.devenv.packages.${system}.default;
in {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # Useful nix related tools
  home.packages =
    (with pkgs; [
      cachix
      niv
    ])
    ++ [devenv];

  home.activation = let
    autoload = config.xdg.configHome + "/nushell/autoload";
  in {
    # FIXME: remove as soon as devenv will start doing this autonomously
    devenvNuAutoload = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${pkgs.nushell}/bin:${pkgs.devenv}/bin:$PATH"
      run mkdir ${autoload}
      run nu -c 'devenv hook nu | save --force ${autoload}/devenv-hook.nu'
    '';
  };
}
