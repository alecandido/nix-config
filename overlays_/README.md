# Overlays

Preset are re-exported by `default.nix`, but all the overlays may be used
individually.

## Avoid automatic loading

These overlays are not meant for automated loading by nix tools, because they might use external information (coming from flake inputs) which would not be available during the automated loading.

The automated loading is prevented by the leading underscore in the folder name.
The remotion of it would make the folder to match the established pattern, causing https://github.com/NixOS/nix/issues/8404.
