# To determine which is the dconf option affected by a certain action (usually GUI), run
# in a shell
# ```sh
# dconf watch /
# ```
# and perform the action.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.plan.dconf;
in {
  options.plan.dconf = {
    enable = mkEnableOption "dconf";
    server = mkEnableOption "dconf on server";
  };

  config = mkIf cfg.enable {
    dconf = {
      enable = true;

      settings = let
        gui = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
          "org/gnome/mutter" = {
            dynamic-workspaces = true;
            edge-tiling = true;
            workspaces-only-on-primary = true;
          };
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "display-brightness-ddcutil@themightydeity.github.com"
              "emoji-copy@felipeftn"
              "tilingshell@ferrarodomenico.com"
            ];
          };
          "org/gnome/shell/extensions/display-brightness-ddcutil" = {
            ddcutil-binary-path = "/etc/profiles/per-user/will/bin/ddcutil";
            show-value-label = true;
          };
          "org/gnome/shell/app-switcher" = {
            current-workspace-only = true;
          };
          "org/gnome/desktop/wm/keybindings" = {
            switch-windows = ["<Alt>Tab"];
            switch-windows-backward = ["<Shift><Alt>Tab"];
          };
        };
        server =
          if cfg.server
          then {
            "org/gnome/settings-daemon/plugins/power" = {
              sleep-inactive-ac-type = "nothing";
            };
          }
          else {};
      in
        gui // server;
    };
  };
}
