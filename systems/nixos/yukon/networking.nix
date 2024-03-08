{pkgs, ...}: {
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 8000];
    };
  };

  systemd.services.villarose-tunnel = {
    enable = true;
    wantedBy = ["multi-user.target"];
    after = ["network.target" "systemd-networkd-wait-online.service"];
    description = "Connect to villarose.";
    script = "${pkgs.openssh}/bin/ssh -N -R 22001:localhost:22 villarose";
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
  };
}
