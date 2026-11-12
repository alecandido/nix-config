let
  # Exact EDID identities from this host. Confirm with `niri msg outputs`;
  # connector names change when the KVM/daisy chain is reconnected.
  primary = "Dell Inc. DELL U3225QE 9WJ0834";
  secondary = "Dell Inc. DELL U2722D JQKD093";
in {
  plan.niri = {
    primaryOutput = primary;
    secondaryOutput = secondary;
    extraConfig = ''
      output "${primary}" {
          // Highest advertised refresh at 4K (120 Hz when the link supports it).
          mode "3840x2160"
          scale 1.5
          transform "normal"
          position x=0 y=0
          focus-at-startup
      }

      output "${secondary}" {
          // The EDID advertises 59.951 Hz, not exactly 60.000 Hz.
          mode "2560x1440@59.951"
          scale 1.0
          // Change to "90" to flip the portrait orientation.
          transform "270"
          // Flush left and centered: (1440 - 2560) / 2 = -560.
          position x=-1440 y=-560
      }
    '';
  };

  # Keep the existing dark preference without GNOME Shell-specific settings.
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
