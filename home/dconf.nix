# To determine which is the dconf option affected by a certain action (usually GUI), run
# in a shell
# ```sh
# dconf watch /
# ```
# and perform the action.
{toggles, ...}: let
  gnome = builtins.elem "gnome" toggles;
  server = builtins.elem "server" toggles;
in {
  dconf = {
    enable = true;
    settings =
      {}
      // (
        if gnome
        then
          ({
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
              };
              "org/gnome/mutter" = {
                dynamic-workspaces = true;
                edge-tiling = true;
                workspaces-only-on-primary = true;
              };
              "org/gnome/shell" = {
                enabled-extensions = ["appindicatorsupport@rgcjonas.gmail.com"];
              };
              "org/gnome/shell/app-switcher" = {
                current-workspace-only = true;
              };
              "org/gnome/desktop/wm/keybindings" = {
                switch-windows = ["<Alt>Tab"];
                switch-windows-backward = ["<Shift><Alt>Tab"];
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
            ))
        else {}
      );
  };
}
