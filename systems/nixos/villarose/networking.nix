{
  pkgs,
  inputs,
  config,
  ...
}: let
  www-villarose = "villarose.annibale.dev";
  www-villarose-certs = "/var/lib/acme/${www-villarose}";
  sws-root = "/home/alessandro/.local/share/www/";
in {
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 8000];
    };
  };

  age.secrets.villarose-annibale-ddns.file = inputs.secrets.villarose-annibale-ddns;

  systemd.services.dynamic-dns = {
    enable = true;
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];
    description = "Update villarose.annibale.dev dynamic DNS entry.";
    path = with pkgs; [curl jq];
    serviceConfig = {
      ExecStart = let
        credentials = config.age.secrets.villarose-annibale-ddns.path;
      in "${pkgs.bash}/bin/bash ${./dns.bash} ${credentials}";
    };
    startAt = "*:00/15:00"; # every 15 minutes
  };

  age.secrets.villarose-https.file = inputs.secrets.villarose-https;

  security.acme = {
    acceptTerms = true;
    defaults.email = "candido.ale@gmail.com";
    certs."${www-villarose}" = {
      dnsProvider = "googledomains";
      environmentFile = config.age.secrets.villarose-https.path;
      reloadServices = ["static-web-server"];
      group = "www";
    };
  };

  services.static-web-server = {
    enable = true;
    root = sws-root;
    listen = "[::]:443";
    configuration = {
      general = {
        http2 = true;
        http2-tls-cert = "${www-villarose-certs}/fullchain.pem";
        http2-tls-key = "${www-villarose-certs}/key.pem";
      };
    };
  };

  users.groups.www = {};
  systemd.services.static-web-server.serviceConfig = {
    SupplementaryGroups = pkgs.lib.mkForce ["" "www"];
    BindReadOnlyPaths = pkgs.lib.mkForce [sws-root www-villarose-certs];
  };
}
