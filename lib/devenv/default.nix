{
  devenv,
  lib,
  symlinkJoin,
  writeShellApplication,
}: let
  launcher = writeShellApplication {
    name = "devenv";
    text = ''
      for arg in "$@"; do
        case "$arg" in
          --)
            break
            ;;
          --reload|--no-reload)
            exec ${lib.getExe devenv} "$@"
            ;;
        esac
      done
      exec ${lib.getExe devenv} --no-reload "$@"
    '';
  };
in
  symlinkJoin {
    name = "devenv-no-reload-${devenv.version}";
    inherit (devenv) version;
    paths = [devenv];
    postBuild = ''
      ln -sf ${lib.getExe launcher} "$out/bin/devenv"
    '';
    meta = devenv.meta // {mainProgram = "devenv";};
  }
