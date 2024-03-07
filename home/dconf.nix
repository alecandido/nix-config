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
                dynamic-workspaces = false;
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
