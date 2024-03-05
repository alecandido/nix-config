{toggles, ...}: let
  enable = builtins.elem "gnome" toggles;
in
  if enable
  then {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  }
  else {}
