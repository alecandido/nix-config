{
  config,
  lib,
  pkgs,
}: let
  cfg = config.plan.mail.work;
  secret = config.age.secrets.mail-work-oauth.path;
in
  pkgs.writeShellApplication {
    name = "oama";
    runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.util-linux];
    text = ''
      umask 077
      : "''${XDG_RUNTIME_DIR:?oama requires a logged-in user session}"
      export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
      exec 9>"$XDG_RUNTIME_DIR/mail-oama.lock"
      flock 9
      runtime_dir="$(mktemp -d "$XDG_RUNTIME_DIR/mail-oama.XXXXXX")"
      mkdir "$runtime_dir/oama"
      runtime_config="$runtime_dir/oama/config.yaml"
      trap 'rm -f "$runtime_config"; rmdir "$runtime_dir/oama" "$runtime_dir"' EXIT
      secret="${secret}"
      printf -v secret_cmd '%q -r %q %q' \
        ${pkgs.jq}/bin/jq '.client_secret // ""' "$secret"

      if ! jq -e '
        type == "object" and
        ((.client_id // "default") | type == "string" and length > 0) and
        ((.tenant_id // "default") | type == "string" and test("^[A-Za-z0-9.-]+$")) and
        ((.client_secret // "") | type == "string")
      ' "$secret" >/dev/null; then
        echo "oama: missing or invalid agenix Microsoft OAuth JSON" >&2
        exit 1
      fi

      jq --arg client ${lib.escapeShellArg cfg.client_id} \
         --arg tenant ${lib.escapeShellArg cfg.tenant_id} \
         --arg secret_cmd "$secret_cmd" '
        {
          encryption: {tag: "KEYRING"},
          services: {
            microsoft: {
              client_id: (.client_id // $client),
              tenant: (.tenant_id // $tenant),
              client_secret_cmd: $secret_cmd,
              auth_scope: "https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/SMTP.Send offline_access"
            }
          }
        }
      ' "$secret" >"$runtime_config"

      case "''${1:-}" in
        access|renew)
          locked="$(timeout 5s ${pkgs.glib.bin}/bin/gdbus call --session \
            --dest org.freedesktop.secrets \
            --object-path /org/freedesktop/secrets/aliases/default \
            --method org.freedesktop.DBus.Properties.Get \
            org.freedesktop.Secret.Collection Locked)"
          if [[ "$locked" != "(<false>,)" ]]; then
            echo "oama: unlock the default keyring in your desktop session first" >&2
            exit 1
          fi
          ;;
      esac

      # oama checks its default config before processing --config.
      XDG_CONFIG_HOME="$runtime_dir" ${lib.getExe pkgs.oama} --config "$runtime_config" "$@"
    '';
  }
