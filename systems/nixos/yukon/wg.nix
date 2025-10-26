{
  config,
  inputs,
  pkgs,
  ...
}: {
  age.secrets.yukon-wg-key.file = inputs.secrets.yukon-wg-key;

  networking = {
    firewall = {
      allowedUDPPorts = [58325];
    };

    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "wlp0s20f3";
      internalInterfaces = ["wg0"];
    };

    wg-quick.interfaces = {
      wg0 = {
        address = [
          "fd31:bf08:57cb::1/128"
          "192.168.26.1/32"
        ];
        # use dnscrypt, or proxy dns as described above
        # dns = ["127.0.0.1"];
        privateKeyFile = config.age.secrets.yukon-wg-key.path;

        # This allows the wireguard server to route your traffic to the internet and
        # hence be like a VPN
        postUp = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
        '';

        # Undo the above
        preDown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
        '';

        peers = [
          {
            publicKey = "npbTfBHakKOz34jdQn6WnYLW/0zDvNowtwTKCUTlsVw=";
            allowedIPs = [
              "fd31:bf08:57cb::100/128"
              "192.168.26.100/32"
            ];
          }
        ];
      };
    };
  };
}
