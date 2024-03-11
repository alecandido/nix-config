{
  config,
  lib,
  ...
}: let
  # TODO: lift to systems/lib, it could be useful even for other machines
  autosshRestarts = builtins.listToAttrs (builtins.map (session: {
      name = "autossh-${session.name}";
      value = {
        after = lib.mkForce ["network-online.target"];
        requires = ["network-online.target"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec =
            lib.mkForce
            "5min";
        };
      };
    })
    config.services.autossh.sessions);
in {
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 8000];
    };
  };

  services.autossh.sessions = [
    {
      extraArguments = "-N -R 22001:localhost:22 villarose";
      monitoringPort = 20000;
      name = "villarose";
      user = "alessandro";
    }
  ];

  systemd.services = autosshRestarts;
}
