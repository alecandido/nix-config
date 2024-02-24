# From scratch to flake

How to go from the system set up by the installer to the a flake-managed configuration.

## Fetch the repo

Enter a shell with `git`:

```sh
nix shell nixpkgs#git --extra-experimental-features nix-command --extra-experimental-features flakes
```

Then, fetch your configurations

```sh
cd .config
git clone https://github.com/user/nixpkgs
```

> Remember to then change remote URL to `git@...`, after registering the SSH key

## Edit the flake

> Skip if you want to use an existing configuration.

It is recommended choosing a new hostname, then go to `systems/nixos/` and add a new
folder named after the chosen hostname.

Then, copy in that folder the file that is located under
`/etc/nixos/hardware-configuration.nix`, and export its content through a `default.nix`
(cf. the existing systems).

Expose the whole system in `systems/nixos.nix`.

Add any new file and directory to Git, to make it available for the flake (also without
committing, but even for that it should be at least staged to make it visible).

## Switch to the flake configuration

Finally, switch to the flake by entering:

```sh
sudo nixos-rebuild switch --flake .#myhostname
```

A reboot never hurts ;)

## Read also

- [This cute world guide](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled) on a similar subject
