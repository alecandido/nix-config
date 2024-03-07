# Nixpkgs

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
