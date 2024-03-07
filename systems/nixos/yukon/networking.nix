{
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 8000];
    };
  };
}
