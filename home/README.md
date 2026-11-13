# User-wide configurations

Managed by home manager.

Optional Haskell and JVM tooling is disabled by default. Enable either in a
system's `extraHomeModules` specification, alongside `plan.tex.enable`:

```nix
plan.haskell.enable = true;
plan.java.enable = true;
```

These extend the tools installed by `plan.neovim.enable` with `plan.neovim.lsp`.
Haskell enables the language server, stylish-haskell and the debug adapter.
Java enables the JVM-based Metals (Scala) and ktlint (Kotlin) tools.

Other optional tools use the following Home Manager toggles:

| Toggle | Default | Tools |
|---|---|---|
| `plan.build.enable` | `true` | GCC, Make and GDB configuration |
| `plan.rust.enable` | `false` | rustfmt (requires Neovim/LSP) |
| `plan.neovim.cppDebug.enable` | `false` | cpptools (requires Neovim/LSP) |
| `plan.recording.enable` | `false` | VHS, independently of amenities |

NixOS also provides `plan.apps.<app>.enable` for `zoom`, `teams`, `spotify`,
`beeper`, `fractal` and `xournalpp` at the system level, outside `extraHomeModules`.
All default to `false`; `rose-oasis` and `ocopoli` enable Zoom, Teams and Spotify.
CJK fonts remain installed unconditionally.
