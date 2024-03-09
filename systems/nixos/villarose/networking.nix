{
  pkgs,
  inputs,
  config,
  ...
}: {
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

  security.acme = {
    acceptTerms = true;
    defaults.email = "candido.ale@gmail.com";
    certs."villarose.annibale.dev" = {
      dnsProvider = "googledomains";
      # Supplying password files like this will make your credentials world-readable
      # in the Nix store. This is for demonstration purpose only, do not use this in production.
      credentialsFile = let
        token = config.age.secrets.villarose-https;
      in "${pkgs.writeText "googledomains-creds" ''
        GOOGLE_DOMAINS_ACCESS_TOKEN_FILE=${token}
      ''}";
    };
  };
}
