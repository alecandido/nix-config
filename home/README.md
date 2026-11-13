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

## Private local Debian packages (Linux)

`programs.localDebInstaller.enable` defaults to `true` in this configuration on
Linux. The reusable module in [`lib/local-debs`](../lib/local-debs) is opt-in;
`home/local-debs` only imports it and sets configuration defaults. It installs
three generic commands:

```sh
install-local-deb [--tauri|--no-tauri] /path/to/package.deb
list-local-debs [--json]
uninstall-local-deb package-name
```

Never add a private package path or name to a Nix expression. Metadata, ELF
patching, wrappers and desktop integration are discovered at runtime only.
Managed package trees and registry live in `~/.local/opt` (directory mode `0700`,
registry `0600`); package archives live in
`~/.local/share/private-debs/installed`. Wrappers are `0700` and desktop entries
`0600`, in owner-only `~/.local/bin` and `~/.local/share/applications` directories.
Icons remain inside the private extracted tree. The original input file is not
deleted or secured by the CLI; keep it outside the repository and in a private
directory yourself. Retained archives are not deleted on uninstall.

Executable script shebangs, including bundled sidecars, are patched at runtime
to public Nix-provided interpreters. Bash, POSIX sh, env and Python are available
by default; additional interpreter packages can be supplied through
`extraRuntimeLibs`. Missing interpreters produce warnings. This also fixes scripts
using `/bin/bash`, which is not available on a standard NixOS installation.

Self-contained Bun executables need special handling: long RPATH rewrites can
break their embedded runtime. These receive interpreter-only ELF patches and a
private wrapper that supplies the same library pool through `LD_LIBRARY_PATH`.
The wrapped payload stays beside the executable in the private package tree.
This applies to directly launched sidecars as well as public command wrappers.

The default library pool supports native CLI, GTK3 and WebKitGTK 4.1 applications.
Add only public library derivations with
`programs.localDebInstaller.extraRuntimeLibs = [ pkgs.someLibrary ];`.
These libraries remain rooted in the Home Manager profile. WebKitGTK 4.0 and
other incompatible ABIs require their matching providers; missing libraries
produce warnings, not fake compatibility symlinks. The audit inspects ELF
dependencies without executing `ldd`; it cannot detect libraries loaded
dynamically with `dlopen`.

The optional watcher defaults to enabled. Drop complete `.deb` files into
`~/.local/share/private-debs` (prefer an atomic rename after copying). A
long-running user service checks the inbox every five seconds once activated,
moving successful inputs to `installed/` and rejected inputs to `failed/`.
Diagnostics go to a private `0600` `watcher.log`, not the systemd journal.
Disable it with `programs.localDebInstaller.watchDirectory.enable = false;`.

Only install trusted packages: user-space executables still have your account's
permissions. Maintainer scripts are never executed. Escaping archive paths,
links, special files, conflicting wrapper names and unresolvable desktop
commands are rejected. This is not a substitute for Debian's system package
manager or a sandbox; packages needing system services or nonstandard launch
layouts may not work. Validation finishes before an upgrade removes the old
version; a subsequent installation failure cleans up the incomplete new version
but does not restore the previous one.
