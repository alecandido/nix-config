{
  config,
  inputs,
  ...
}: {
  age.secrets.donaldville-wg-key.file = inputs.secrets.donaldville-wg-key;

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [
        "fd31:bf08:57cb::100/128"
        "192.168.26.100/32"
      ];

      dns = ["1.1.1.1"];

      # NOTE: this generates a `/etc/wireguard/wg0.conf` containing an
      # `Interface.PostUp` entry, which sets the private key from the decrypted file
      # available at runtime from agenix
      # To use this file in an external application, replace `Interface.PostUp` with an
      # `Interface.PrivateKey` entry, with the plain unencrypted private key
      privateKeyFile = config.age.secrets.donaldville-wg-key.path;

      peers = [
        {
          publicKey = "cF6ZiBFPmN/CMGXmXGC8bdo75m2GKM1xkKOJQemminU=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "2.229.167.187:58325";
        }
      ];
    };
  };
}
