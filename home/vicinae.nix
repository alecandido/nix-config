{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Newer companions use browser IPC unsupported by the pinned Vicinae.
  browserCompanion = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon {
    pname = "vicinae-browser-companion";
    version = "1.0.0";
    addonId = "firefox@vicinae.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/4839406/vicinae-1.0.0.xpi";
    sha256 = "996c056d556be9c9c97494403672463117973e7d1bfc10fad9f719f8c07d9426";
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
    programs.firefox.policies.ExtensionSettings."firefox@vicinae.com".updates_disabled = true;

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
