{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  config = inputs.self.nixosConfigurations.rose-oasis.config.home-manager.users.alessandro;
  mac = inputs.self.darwinConfigurations.donaldville.config.home-manager.users.alessandro;
  package = config.programs.devenv.package;
  fakeDevenv =
    (pkgs.writeShellScriptBin "devenv" ''
      printf '%s\n' "$@"
    '').overrideAttrs {
      version = "test";
      meta.mainProgram = "devenv";
    };
  wrapped = pkgs.callPackage ../lib/devenv {devenv = fakeDevenv;};
in
  assert lib.hasPrefix "devenv-no-reload-" package.name;
  assert lib.hasPrefix "devenv-no-reload-" mac.programs.devenv.package.name;
  assert config.programs.devenv.enableNushellIntegration;
  assert mac.programs.devenv.enableNushellIntegration;
    pkgs.runCommand "devenv-defaults-check" {} ''
      check() {
        expected="$1"
        shift
        ${lib.getExe wrapped} "$@" > actual
        printf '%s\n' "$expected" > expected
        diff -u expected actual
      }

      check $'--no-reload\nshell' shell
      check $'--no-reload\nhook\nnu' hook nu
      check $'shell\n--reload' shell --reload
      check $'shell\n--no-reload' shell --no-reload
      check $'--no-reload\nshell\n--\necho\n--reload' shell -- echo --reload
      check $'--no-reload\nshell\nprintf\nargument with spaces' shell printf 'argument with spaces'

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      ${lib.getExe package} --user-config ${
        pkgs.writeText "devenv-config.json" config.xdg.configFile."devenv/config.yaml".text
      } user-config validate
      ${lib.getExe package} hook nu > hook.nu
      test -s hook.nu
      touch "$out"
    ''
