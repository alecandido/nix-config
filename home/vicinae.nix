{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  browserCompanion = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon {
    pname = "vicinae-browser-companion";
    version = "1.2.0";
    addonId = "firefox@vicinae.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/5224510/vicinae-1.2.0.xpi";
    sha256 = "a0ef790a2d1e749510ab953e65b34a8e8e04244cc4f84e47d0028882872b2280";
    meta = {
      description = "Vicinae browser integration";
      homepage = "https://addons.mozilla.org/firefox/addon/vicinae/";
    };
  };
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
    }) (["nix" "firefox" "github" "bitwarden"] ++ lib.optional config.plan.niri.enable "niri");
  settings = (pkgs.formats.json {}).generate "vicinae-settings.json" {
    search_files_in_root = true;
    favorites = ["files:search"];
    theme.dark.name = "nord";
    providers.clipboard.preferences.monitoring = false;
    providers."@bl4zee1g/vicinae-extension-bitwarden-0".preferences.rbwPath =
      lib.getExe config.programs.rbw.package;
  };
in {
  options.plan.vicinae.enable = lib.mkEnableOption "the Vicinae launcher";

  config = lib.mkIf config.plan.vicinae.enable {
    home.packages = [pkgs.vicinae pkgs.pinentry-qt];
    programs.rbw.enable = true;
    programs.firefox.profiles.default.extensions.packages = [browserCompanion];

    xdg.dataFile = builtins.listToAttrs (map (extension:
      lib.nameValuePair "vicinae/extensions/${extension.name}" {
        source = extension;
      })
    extensions);

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
