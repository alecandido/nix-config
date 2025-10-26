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
      # use dnscrypt, or proxy dns as described above
      dns = ["127.0.0.1"];
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
