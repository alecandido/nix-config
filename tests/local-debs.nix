{
  inputs,
  pkgs,
}: let
  home = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../lib/local-debs
      {
        home = {
          username = "local-deb-test";
          homeDirectory = "/home/local-deb-test";
          stateVersion = "26.05";
        };
        programs.localDebInstaller.enable = true;
      }
    ];
  };
  cfg = home.config;
  watcher = pkgs.lib.head cfg.systemd.user.services.local-debs.Service.ExecStart;
  script = name: pkgs.lib.findFirst (package: package.name == name) (throw "Missing ${name}") cfg.home.packages;
in
  assert cfg.systemd.user.paths.local-debs.Path.DirectoryNotEmpty == "%h/.local/share/private-debs";
  assert cfg.systemd.user.services.local-debs.Service.Type == "simple";
  assert pkgs.lib.elem "$HOME/.local/bin" cfg.home.sessionPath;
    pkgs.runCommand "local-debs-check" {
      nativeBuildInputs = [
        (script "install-local-deb")
        (script "list-local-debs")
        (script "uninstall-local-deb")
        pkgs.stdenv.cc
        pkgs.dpkg
        pkgs.jq
        pkgs.patchelf
        pkgs.python3
        pkgs.bun
        pkgs.shellcheck
      ];
    } ''
      test -d ${cfg.home.path}/lib
      export HOME="$TMPDIR/home"
      mkdir -m 700 -p "$HOME/.local/opt/fixtures"
      cd "$HOME/.local/opt/fixtures"
      bash ${./local-debs.sh}
      shellcheck ${watcher}
      bash ${./local-debs-watcher.sh} ${watcher}
      touch "$out"
    ''
