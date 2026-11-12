{
  config,
  lib,
  pkgs,
  ...
}: let
  extensionSource = pkgs.fetchFromGitHub {
    owner = "vicinaehq";
    repo = "extensions";
    rev = "181904331f5289b53ee3443f98cfa5441d399f35";
    hash = "sha256-UR269g8GwB5jywGcxqViVscjl8gtvRO9XjtCoGnUbSs=";
  };
  mkExtension = pkgs.callPackage "${pkgs.vicinae.src}/nix/mkVicinaeExtension.nix" {};
  extensions = map (name:
    mkExtension {
      pname = "vicinae-extension-${name}";
      version = "0";
      src = "${extensionSource}/extensions/${name}";
      npmFlags = ["--legacy-peer-deps"];
    }) ["nix" "niri" "firefox" "github" "bitwarden"];
  settings = (pkgs.formats.json {}).generate "vicinae-settings.json" {
    search_files_in_root = true;
    favorites = ["files:search"];
    theme.dark.name = "nord";
    providers.clipboard.preferences.monitoring = false;
    providers."@bl4zee1g/vicinae-extension-bitwarden-0".preferences.rbwPath =
      lib.getExe config.programs.rbw.package;
  };
in {
  config = lib.mkIf config.plan.niri.enable {
    home.packages = [pkgs.vicinae pkgs.pinentry-qt];
    programs.rbw.enable = true;

    xdg.dataFile = builtins.listToAttrs (map (extension:
      lib.nameValuePair "vicinae/extensions/${extension.name}" {
        source = extension;
      })
    extensions);

    plan.niri.noctaliaSettings.widget.launcher.actions.left =
      lib.mkDefault "exec ${lib.getExe pkgs.vicinae} toggle";

    systemd.user.services.vicinae = {
      Unit = {
        Description = "Vicinae application and file launcher";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        Requires = ["dbus.socket"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.vicinae} server";
        Environment = ["VICINAE_OVERRIDES=${settings}"];
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
