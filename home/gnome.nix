{toggles, ...}: let
  enable = builtins.elem "gnome" toggles;
  server = builtins.elem "server" toggles;
in
  if enable
  then {
    dconf = {
      enable = true;
      settings =
        {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        }
        // (
          if server
          then {
            "org/gnome/settings-daemon/plugins/power" = {
              sleep-inactive-ac-type = "nothing";
            };
          }
          else {}
        );
    };
  }
  else {}
