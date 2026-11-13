{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  niri = inputs.self.nixosConfigurations.rose-oasis.config;
  gnome = inputs.self.nixosConfigurations.ocopoli.config;
  home = niri.home-manager.users.alessandro;
  agent = home.systemd.user.services.nm-applet;
in
  assert lib.elem pkgs.networkmanager-openconnect niri.networking.networkmanager.plugins;
  assert home.systemd.user.startServices;
  assert lib.elem "graphical-session.target" agent.Install.WantedBy;
  assert lib.elem "graphical-session.target" agent.Unit.PartOf;
  assert agent.Unit.ConditionEnvironment == "WAYLAND_DISPLAY";
  assert !(niri.systemd.user.services ? nm-applet);
  assert lib.elem "nm-applet" home.plan.niri.noctaliaSettings.widget.tray.hidden;
  assert !(gnome.home-manager.users.alessandro.systemd.user.services ? nm-applet);
  assert !(lib.elem pkgs.networkmanager-openconnect gnome.networking.networkmanager.plugins);
    pkgs.runCommand "niri-vpn-check" {} ''
      test -x ${pkgs.networkmanagerapplet}/bin/nm-applet
      test -x ${pkgs.networkmanagerapplet}/bin/nm-connection-editor
      test -s ${pkgs.networkmanager-openconnect}/lib/NetworkManager/VPN/nm-openconnect-service.name
      test -s ${home.xdg.configFile."systemd/user/nm-applet.service".source}
      test -s ${home.xdg.configFile."noctalia/config.toml".source}
      touch "$out"
    ''
