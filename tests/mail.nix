{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  makeHome = ready: extraModules:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs;};
      modules =
        [
          ../home/mail
          inputs.agenix.homeManagerModules.age
          {
            home = {
              username = "mail-test";
              homeDirectory = "/tmp/mail-test";
              stateVersion = "26.05";
            };
            plan.mail = {
              enable = true;
              work.address = "work@example.org";
              secrets = lib.optionalAttrs ready {
                personal = builtins.toFile "mail-personal-test.age" "synthetic encrypted fixture";
                work = builtins.toFile "mail-work-test.age" "synthetic encrypted fixture";
              };
            };
          }
        ]
        ++ extraModules;
    }).config;
  ready = makeHome true [];
  pending = makeHome false [];
  custom = makeHome true [
    {
      plan.mail.work = {
        client_id = "approved-client";
        tenant_id = "example.org";
        thunderbirdOAuthOverride = true;
      };
    }
  ];
  accounts = ready.home.file."/tmp/mail-test/.config/aerc/accounts.conf".text;
  thunderbird = ready.home.file.".thunderbird/mail/user.js".text;
  oauthConfig = {
    plan.mail.work = {
      client_id = "default-client";
      tenant_id = "organizations";
    };
    age.secrets.mail-work-oauth.path = "\${XDG_RUNTIME_DIR}/credentials with spaces.json";
  };
  oauth = import ../home/mail/oauth.nix {
    inherit lib pkgs;
    config = oauthConfig;
  };
  guardedOauth = import ../home/mail/oauth.nix {
    inherit lib;
    config = oauthConfig;
    pkgs =
      pkgs
      // {
        glib.bin = pkgs.writeShellScriptBin "gdbus" ''
          printf '(<%s>,)\n' "$MAIL_TEST_LOCKED"
        '';
        oama = pkgs.writeShellScriptBin "oama" ''
          echo synthetic-access-token
        '';
      };
  };
in
  assert ready.plan.mail.credentialsReady && ready.age.secrets.mail-personal.enable;
  assert !pending.plan.mail.credentialsReady && !pending.age.secrets.mail-personal.enable;
  assert ready.services.mbsync.enable && !pending.services.mbsync.enable;
  assert ready.systemd.user.timers.mbsync.Timer.OnUnitActiveSec == "5m";
  assert lib.hasInfix "source = maildir:///tmp/mail-test/.local/share/mail/personal" accounts;
  assert lib.hasInfix "source = maildir:///tmp/mail-test/.local/share/mail/work" accounts;
  assert lib.hasInfix "--account=work" accounts && lib.hasInfix "copy-to = Sent Items" accounts;
  assert !lib.hasInfix ".local/share/mail" thunderbird;
  assert lib.hasInfix "[ProfD]ImapMail/" thunderbird;
  assert lib.hasInfix "/%5BGmail%5D/Sent%20Mail" thunderbird;
  assert lib.hasInfix ".oauth2.clientId\", \"approved-client\"" custom.home.file.".thunderbird/mail/user.js".text;
  assert lib.hasInfix "https://login.microsoftonline.com/example.org/oauth2/v2.0/token" custom.home.file.".thunderbird/mail/user.js".text;
  assert lib.all (a: a.assertion) ready.assertions;
    pkgs.runCommand "mail-check" {
      nativeBuildInputs = [pkgs.jq pkgs.python3];
    } ''
      grep -F 'AuthMechs XOAUTH2' ${ready.xdg.configFile.isyncrc.source}
      grep -F 'Expunge Both' ${ready.xdg.configFile.isyncrc.source}
      grep -F 'auth xoauth2' ${ready.xdg.configFile."msmtp/config".source}
      grep -F 'passwordeval ' ${ready.xdg.configFile."msmtp/config".source}
      grep -F 'text/html = ${pkgs.w3m}/bin/w3m -dump' ${ready.home.file."/tmp/mail-test/.config/aerc/aerc.conf".source}

      export HOME="$TMPDIR/home"
      export XDG_STATE_HOME="$HOME/.local/state"
      export XDG_RUNTIME_DIR="$TMPDIR/runtime"
      mkdir -m700 -p "$HOME" "$XDG_RUNTIME_DIR"
      secret="$XDG_RUNTIME_DIR/credentials with spaces.json"
      printf '%s\n' '{"client_id":"approved-client","tenant_id":"example.org"}' >"$secret"
      ${lib.getExe oauth} printenv > environment
      grep -F 'approved-client' environment
      grep -F 'https://login.microsoftonline.com/example.org/oauth2/v2.0/token' environment
      test "$(find "$XDG_RUNTIME_DIR" -type d -name 'mail-oama.*' | wc -l)" -eq 0

      printf '%s\n' '{}' >"$secret"
      ${lib.getExe oauth} printenv > environment
      grep -F 'default-client' environment
      grep -F 'https://login.microsoftonline.com/organizations/oauth2/v2.0/token' environment

      export MAIL_TEST_LOCKED=true
      if ${lib.getExe guardedOauth} access work@example.org > output 2> error; then
        echo "oama accepted a locked keyring" >&2
        exit 1
      fi
      test ! -s output
      grep -F 'unlock the default keyring' error
      export MAIL_TEST_LOCKED=false
      ${lib.getExe guardedOauth} access work@example.org > output
      grep -Fx 'synthetic-access-token' output

      printf '%s\n' '{"tenant_id":"../invalid"}' >"$secret"
      if ${lib.getExe oauth} printenv > output 2> error; then
        echo "oama accepted an invalid tenant" >&2
        exit 1
      fi
      test ! -s output
      grep -F 'missing or invalid agenix Microsoft OAuth JSON' error
      rm "$secret"
      if ${lib.getExe oauth} access work@example.org > output 2> error; then
        echo "oama accepted missing credentials" >&2
        exit 1
      fi
      test ! -s output
      test "$(find "$XDG_RUNTIME_DIR" -type d -name 'mail-oama.*' | wc -l)" -eq 0

      export XDG_CONFIG_HOME="$HOME/.config"
      export TERM=xterm-256color
      for account in personal work; do
        mkdir -p "$HOME/.local/share/mail/$account/INBOX"/{cur,new,tmp}
      done
      sed "s|/tmp/mail-test|$HOME|g" ${ready.home.file."/tmp/mail-test/.config/aerc/accounts.conf".source} > accounts.conf
      python3 <<'PY'
      import fcntl
      import os
      import pty
      import select
      import signal
      import struct
      import termios
      import time

      pid, terminal = pty.fork()
      if pid == 0:
          fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 100, 0, 0))
          os.execl("${pkgs.aerc}/bin/aerc", "aerc", "-I",
                   "-C", "${ready.home.file."/tmp/mail-test/.config/aerc/aerc.conf".source}",
                   "-A", os.path.abspath("accounts.conf"),
                   "-B", "${ready.home.file."/tmp/mail-test/.config/aerc/binds.conf".source}")
      output = b""
      deadline = time.monotonic() + 15
      try:
          while b"Connected" not in output and time.monotonic() < deadline:
              if select.select([terminal], [], [], 1)[0]:
                  try:
                      output += os.read(terminal, 65536)
                  except OSError:
                      break
          assert b"Connected" in output, repr(output)
      finally:
          os.kill(pid, signal.SIGKILL)
          os.waitpid(pid, 0)
          os.close(terminal)
      PY
      touch "$out"
    ''
