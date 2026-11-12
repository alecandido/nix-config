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

Noctalia supplies the bar, notifications, wallpaper controls, lock
screen and idle management, replacing Waybar, Fuzzel, Mako and Swayidle/Swaylock.
It uses the Noctalia package already pinned in nixpkgs, with a Nord dark palette
and otherwise mostly upstream visual defaults. Soteria remains the Polkit agent.
Nautilus (Files) is available from the launcher and handles folders by default;
GVfs and UDisks provide network-share and removable-drive support. The existing
GTK file chooser remains unchanged. This setup is enabled only for Niri.
GTK applications, including Firefox's browser UI, use Inter at 10 points;
terminal fonts and website font preferences remain unchanged.

Vicinae provides the application and file launcher on `Super+D`, `Super+Space`,
and the bar's launcher button, using the cached nixpkgs package and Nord dark
theme. It runs as a graphical-session-bound user service on every NixOS host,
including GNOME; macOS is unchanged. On GNOME, open it from the applications
overview; existing GNOME shortcuts are unchanged.
File results appear in the main search; **Search Files** opens a dedicated view.
Its indexer scans the home directory locally; the first scan may take time.
Configure search paths and exclusions in Vicinae's extension settings.
Clipboard history remains disabled. Vicinae's GUI settings stay writable, but
the declarative theme, root file search, favorites and clipboard policy take
precedence through `VICINAE_OVERRIDES`.

Nix, Firefox (bookmarks/history), GitHub, and Bitwarden extensions are built from a
pinned upstream revision and installed declaratively on NixOS hosts. The Niri
extension is installed only with Niri. GitHub
requires a personal access token entered in its extension preferences; never
put the token in Nix settings, which are copied to the public-readable Nix store.

Bitwarden uses the separately authenticated `rbw` client, with `pinentry-qt`
available for graphical password prompts. Its account configuration and vault
remain outside the Nix store. Home Manager enforces a five-minute `rbw` auto-lock
timeout while preserving the other account settings. Changing the timeout stops
the current agent, so the next vault access requires unlocking again.

After rebuilding, configure and authenticate it once:

```sh
rbw config set email "your-bitwarden-email"
rbw config set pinentry "$(command -v pinentry-qt)"
rbw register
rbw login
rbw sync
```

`rbw register` is required for the official Bitwarden service and prompts for
your personal API key. For EU-hosted accounts, first run
`rbw config set base_url https://api.bitwarden.eu`.
Open **Browse Bitwarden Vault** in Vicinae to search entries.

For live Firefox tabs, the
[Vicinae browser companion](https://addons.mozilla.org/en-US/firefox/addon/vicinae/)
is installed declaratively on NixOS hosts. Restart Firefox after rebuilding.
The signed companion is pinned to 1.0.0 for compatibility with Vicinae 0.29.2;
automatic updates are disabled for this addon because 1.2.0 uses incompatible IPC.
Vicinae supplies the native messaging bridge when it starts.
Open Vicinae, choose **Search Browser Tabs**, search a title or URL, and press
Enter to focus the selected tab. No BroTab installation is needed.

The reusable desktop lives in `home/niri/`. Monitor identities and geometry live
only in `systems/nixos/rose-oasis/home/niri.nix`. The exact EDID strings are
hardware identifiers, not credentials. Check them after logging in with:

```sh
niri msg outputs
niri validate
```

The 4K monitor uses the highest advertised refresh rate at 125% scale. Actual
refresh depends on the KVM/link bandwidth. The portrait monitor uses its
advertised 59.951 Hz mode at 100% scale, immediately to the left; change `"270"`
to `"90"` in the host file to reverse its rotation.

Positions use logical pixels: the primary is `3072x1728` at `(0, 0)`, and the
portrait screen is `1440x2560` at `(-1440, -416)`, centered vertically against the
primary. Adjust `position` in the host file to fine-tune the physical arrangement.

Niri and GTK applications use the installed Adwaita cursor theme at size 24.
Without an available theme, Niri's fixed-size fallback cursor can look oversized
on the unscaled portrait display. Rose-oasis uses the Asia/Dubai timezone and
English (US) locale defaults, without the shared Italian regional overrides.

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
| `Return` / `D` or `Space` / `Q` | Ghostty / Vicinae launcher / close |
| `S` / `Shift+,` | Control center / Noctalia settings |
| `Tab` / `O` / `Shift+/` | Previous workspace / overview / binding help |
| `PageUp` / `PageDown` | Focus the workspace above / below |
| `Shift+PageUp` / `Shift+PageDown` | Move the column to the workspace above / below |
| `V` / `Shift+V` | Toggle window floating / switch floating-tiled focus |
| `Alt+L` / `Shift+E` | Lock / quit |

`Print`, `Super+Print`, and `Alt+Print` capture a selection, screen, and window.
Volume and brightness keys use Noctalia's controls and OSDs. Media keys control
Noctalia's active player: play/pause, dedicated pause, stop, next and previous
track; these controls also work while locked. `ddcutil` is available
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
