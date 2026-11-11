{
  config,
  inputs,
  pkgs,
  ...
}: let
  credentials = config.age.secrets.rose-oasis-wifi;
in {
  age.secrets.rose-oasis-wifi.file = inputs.secrets.rose-oasis-wifi;

  networking.networkmanager = {
    wifi = {
      backend = "iwd";
      powersave = false;
    };

    settings.main.iwd-config-path = "/var/lib/iwd";

    ensureProfiles = {
      environmentFiles = [credentials.path];
      profiles = {
        corporate-wifi = {
          connection = {
            id = "$CORPORATE_SSID";
            uuid = "752a15b3-89d9-43b4-9b5b-c76d399e3059";
            type = "wifi";
            autoconnect = true;
            autoconnect-priority = 100;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$CORPORATE_SSID";
          };
          wifi-security.key-mgmt = "wpa-eap";
          "802-1x".eap = "external";
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
        guest-wifi = {
          connection = {
            id = "$GUEST_SSID";
            uuid = "5a8777d6-0d49-4351-af6e-56c1cd907c33";
            type = "wifi";
            autoconnect = false;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$GUEST_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$GUEST_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };

  systemd.services.NetworkManager = {
    requires = ["iwd.service"];
    after = ["iwd.service"];
    restartTriggers = [credentials.file];
  };

  systemd.services.NetworkManager-ensure-profiles.restartTriggers = [credentials.file];

  systemd.services.iwd = {
    restartTriggers = [credentials.file];
    serviceConfig = {
      EnvironmentFile = credentials.path;
      UMask = "0077";
    };
    preStart = ''
      [[ "$CORPORATE_SSID" =~ ^[a-zA-Z0-9_-]+$ && "$GUEST_SSID" =~ ^[a-zA-Z0-9_-]+$ ]] || {
        echo "Wi-Fi provisioning requires simple ASCII SSIDs for iwd filenames." >&2
        exit 1
      }
      install -d -m 700 /var/lib/iwd
      ${pkgs.envsubst}/bin/envsubst -i ${pkgs.writeText "corporate-wifi.8021x" ''
        [Settings]
        AutoConnect=true

        [Security]
        EAP-Method=PEAP
        EAP-Identity=$CORPORATE_ANONYMOUS_IDENTITY
        EAP-PEAP-Phase2-Method=MSCHAPV2
        EAP-PEAP-Phase2-Identity=$CORPORATE_IDENTITY
        EAP-PEAP-Phase2-Password=$CORPORATE_PASSWORD
      ''} > "/var/lib/iwd/$CORPORATE_SSID.8021x"
      ${pkgs.envsubst}/bin/envsubst -i ${pkgs.writeText "guest-wifi.psk" ''
        [Settings]
        AutoConnect=false

        [Security]
        Passphrase=$GUEST_PSK
      ''} > "/var/lib/iwd/$GUEST_SSID.psk"
      chmod 600 "/var/lib/iwd/$CORPORATE_SSID.8021x" "/var/lib/iwd/$GUEST_SSID.psk"
    '';
  };
}
