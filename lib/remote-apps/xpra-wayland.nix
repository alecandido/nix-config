{
  lib,
  pkgs,
}: let
  server = pkgs.xpra.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.wayland-scanner];
    buildInputs =
      old.buildInputs
      ++ (with pkgs; [
        wayland
        wlroots_0_19
        libxkbcommon
        libdrm
        pixman
      ]);
    setupPyBuildFlags =
      old.setupPyBuildFlags
      ++ [
        "--with-wayland_client"
        "--with-wayland_server"
      ];
    postPatch =
      old.postPatch
      + ''
        substituteInPlace setup.py \
          --replace-fail /usr/share/wayland-protocols ${pkgs.wayland-protocols}/share/wayland-protocols
      '';
  });
in
  (pkgs.writeShellScriptBin "xpra-wayland" ''
    exec ${lib.getExe' server "xpra"} "$@"
  '').overrideAttrs {
    passthru = {inherit server;};
  }
