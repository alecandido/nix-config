{
  pkgs,
  inputs,
  ...
}: let
  # FIXME: dirty trick
  # since the flake depend directly on nixpkgs, it has its own `config.allowUnfree`, and
  # I didn't find any way to set it to true (required for `languagetool`) - thus I'm
  # importing the content of `default.nix`, and repeating the same line present in the
  # flake
  addons = (import inputs.firefox-addons) {inherit (pkgs) fetchurl lib stdenv;};
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    # Cf. about:policies#documentation
    policies = {
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";
      Homepage = {
        URL = "https://annibale.dev";
        Locked = true;
        StartPage = "previous-session";
      };
    };
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        extensions = with addons; [
          addons."10ten-ja-reader"
          bitwarden
          languagetool
          notifier-for-github
          refined-github
          tab-session-manager
        ];
        search = {
          force = true;
          order = ["Google" "Wikipedia"];
          engines = {
            "Google".metaData.alias = "@g";

            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };

            "Bing".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
          };
        };
      };
    };
  };
}
