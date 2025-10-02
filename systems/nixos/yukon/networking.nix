{
  services.openssh = {
    enable = true;
    ports = [22 443 2222];

    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443 2222];
    };

    interfaces = {
      wlp0s20f3.ipv4.addresses = [
        {
          address = "192.168.1.227";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "192.168.1.254";
  };
}
