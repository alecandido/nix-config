{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  niri = inputs.self.nixosConfigurations.rose-oasis.config;
  gnome = inputs.self.nixosConfigurations.ocopoli.config;
  home = niri.home-manager.users.alessandro;
in
  assert lib.elem pkgs.networkmanager-openconnect niri.networking.networkmanager.plugins;
  assert niri.programs.nm-applet.enable && niri.programs.nm-applet.indicator;
  assert lib.elem "graphical-session.target" niri.systemd.user.services.nm-applet.wantedBy;
  assert lib.elem "graphical-session.target" niri.systemd.user.services.nm-applet.partOf;
  assert lib.elem "nm-applet" home.plan.niri.noctaliaSettings.widget.tray.hidden;
  assert !gnome.programs.nm-applet.enable;
  assert !(lib.elem pkgs.networkmanager-openconnect gnome.networking.networkmanager.plugins);
    pkgs.runCommand "niri-vpn-check" {} ''
      test -x ${niri.programs.nm-applet.package}/bin/nm-applet
      test -x ${niri.programs.nm-applet.package}/bin/nm-connection-editor
      test -s ${pkgs.networkmanager-openconnect}/lib/NetworkManager/VPN/nm-openconnect-service.name
      test -s ${home.xdg.configFile."noctalia/config.toml".source}
      touch "$out"
    ''
