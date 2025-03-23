{
  pkgs,
  inputs,
  ...
}: let
  addons = builtins.getAttr pkgs.system inputs.firefox-addons.packages;
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
        extensions.packages = with addons; [
          addons."10ten-ja-reader"
          bitwarden
          # FIXME: this is just a lie, since I did not find a way to `allowUnfree` for
          # the flake dependency
          # https://discourse.nixos.org/t/how-to-allowunfree-in-dependant-flake/41015
          (languagetool.overrideAttrs {meta.license.free = true;})
          notifier-for-github
          refined-github
          tab-session-manager
        ];
        search = {
          force = true;
          order = ["google" "wikipedia"];
          # builtin ones are found here:
          # https://searchfox.org/mozilla-central/source/browser/components/search/extensions
          engines = {
            "google".metaData.alias = "@g";

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

            "bing".metaData.hidden = true;
            "ddg".metaData.hidden = true;
            "ebay".metaData.hidden = true;
          };
        };
      };
    };
  };
}
