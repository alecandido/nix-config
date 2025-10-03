{pkgs, ...}: {
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443 2222 3389];
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

  # RDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session"; # gnome wayland session
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop = {
    wantedBy = ["graphical.target"]; # for starting the unit automatically at boot
  };
  services.displayManager.autoLogin.enable = false;
  services.getty.autologinUser = null;
}
