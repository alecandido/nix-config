{toggles, ...}: let
  enable = builtins.elem "gnome" toggles;
  server = builtins.elem "server" toggles;
in
  if enable
  then {
    dconf = {
      enable = true;
      settings.org.gnome =
        {
          desktop.interface.color-scheme = "prefer-dark";
          mutter.dynamic-workspaces = true;
        }
        // (
          if server
          then {
            settings-daemon.plugins.power.sleep-inactive-ac-type = "nothing";
          }
          else {}
        );
    };
  }
  else {}
