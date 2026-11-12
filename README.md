# Nix configuration

My own nix settings.

## Installation

For a new NixOS system, install with Calamares from USB drive, then follow [this
guide](./nixos-to-flake.md) to start using flakes.

## Configurations location

### Common to all suitable systems

- home-manager: `home/`
- NixOS: `etc/nixos/`
- darwin: `etc/darwin/`

### Common to most system

They are in the location mentioned in the above section, but their value could be
conditioned, or directly extracted, from configurations defined in `systems/`.

### System-specific

In this case, the configuration is directly defined in `systems/`, without the overhead
of defining a new option in a module, and then setting in the common one.

## Niri desktop

`plan.desktop = "niri"` in a NixOS host selects Niri instead of GNOME and enables
`plan.niri.enable` in Home Manager. The default remains `"gnome"`; only
`rose-oasis` opts in. GDM remains the login screen. After rebuilding, log out
and select the Niri session.

Noctalia supplies the bar, launcher, notifications, wallpaper controls, lock
screen and idle management, replacing Waybar, Fuzzel, Mako and Swayidle/Swaylock.
It uses the Noctalia package already pinned in nixpkgs, with a Nord dark palette
and otherwise mostly upstream visual defaults. Soteria remains the Polkit agent.

The reusable desktop lives in `home/niri/`. Monitor identities and geometry live
only in `systems/nixos/rose-oasis/home/niri.nix`. The exact EDID strings are
hardware identifiers, not credentials. Check them after logging in with:

```sh
niri msg outputs
niri validate
```

The 4K monitor uses the highest advertised refresh rate at 150% scale. Actual
refresh depends on the KVM/link bandwidth. The portrait monitor uses its
advertised 59.951 Hz mode at 100% scale, immediately to the left; change `"270"`
to `"90"` in the host file to reverse its rotation.

Positions use logical pixels: the primary is `2560x1440` at `(0, 0)`, and the
portrait screen is `1440x2560` at `(-1440, -560)`, centered vertically against the
primary. Adjust `position` in the host file to fine-tune the physical arrangement.

For interactive drag-and-drop arrangement, run this from the repository inside
Niri:

```sh
nix run --inputs-from . nixpkgs#wdisplays
```

GUI changes affect the running session, not the Nix configuration. Inspect the
result with `niri msg outputs` and copy the desired positions into the host file
to make them persistent; reconnects or config reloads can restore declared
settings.

| Super binding | Action |
| --- | --- |
| `1` / `2` / `3` / `4` / `5` | code / web / work / comms / aux |
| `Shift+1` through `Shift+5` | Send the focused column to that named workspace |
| `H J K L` / `Shift+H J K L` | Focus / move columns and stacked windows |
| `Ctrl+H L` / `Ctrl+Shift+H L` | Focus monitor / send column to monitor |
| `,` / `.` / `[` / `]` | Consume/expel adjacent windows / stack/unstack |
| `R` / `Shift+R` / `F` / `Shift+F` / `C` | Width / height / maximize / fullscreen / center |
| `Return` / `D` or `Space` / `Q` | Ghostty / Noctalia launcher / close |
| `S` / `Shift+,` | Control center / Noctalia settings |
| `Tab` / `O` / `Shift+/` | Previous workspace / overview / binding help |
| `Alt+L` / `Shift+E` | Lock / quit |

`Print`, `Super+Print`, and `Alt+Print` capture a selection, screen, and window.
Volume and brightness keys use Noctalia's controls and OSDs. `ddcutil` is available
for supported external-monitor brightness controls. Idle locks after 10 minutes,
blanks displays after 15, and locks before sleep using the existing login PAM
stack. Noctalia runs as one systemd user service tied to the graphical session.

Open settings with `Super+Shift+,` to choose wallpapers and customize the shell.
Declarative overrides belong in `plan.niri.noctaliaSettings`, for example:

```nix
plan.niri.noctaliaSettings = {
  theme.builtin = "Catppuccin";
  bar.main.position = "bottom";
};
```

These settings merge with Noctalia's built-in defaults. GUI changes are saved
separately in `~/.local/state/noctalia/settings.toml` and take precedence over the
declarative layer; remove the corresponding GUI overrides when a Nix change
appears to be ignored. Clipboard history is disabled unless explicitly enabled.

Mail/chat and standalone password-manager windows are blocked from screencasts.
This does not hide notification text, bar titles, browser-extension popups, or
third-party screenshot previews; avoid showing sensitive content there.

Every Home Manager build validates both Niri's KDL and Noctalia's TOML with the
pinned binaries:

```sh
# On Linux, build just the validated config without activating anything:
nix build '.#nixosConfigurations.rose-oasis.config.home-manager.users.alessandro.xdg.configFile."niri/config.kdl".source' --no-link
# Build the complete Home Manager configuration:
nix build .#nixosConfigurations.rose-oasis.config.home-manager.users.alessandro.home.activationPackage --no-link
```
