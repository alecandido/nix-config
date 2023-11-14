# TODOs

- [ ] fix `devenv` overlay
- [ ] fix the `toggles` mechanism
- [ ] allow submodules with home-manager (to save `neovim` configs)
- [ ] feature-gate neovim LSP servers

  - they are the biggest part of neovim (the other configs are light)
  - mostly at the level of Nix (avoid installing some packages)
  - propagate the information with an environment variable and catch it inside neovim
    as well (to disable the related configs and avoid failing)

    - in the first place let it fail
    - and then fix the failures with a test case

## nix-user-chroot instructions

### Installation

From the [official instructions](https://github.com/nix-community/nix-user-chroot#installation).

```sh
mkdir -m 0755 /path/to/nix
nix-user-chroot /path/to/nix bash -c "curl -L https://nixos.org/nix/install | bash"
```

### Usage

```sh
nix-user-chroot /path/to/nix bash -l
```

**NOTE:** remember to copy the line:

```sh
if [ -e /path/to/home/.nix-profile/etc/profile.d/nix.sh ]; then 
  . /path/to/home/.nix-profile/etc/profile.d/nix.sh; 
fi # added by Nix installer
```

to the sourced script of the chosen shell (e.g. Nix adds it by default to Bash in
`.bashrc`, but I'm using ZSH, so I need a similar line in `.zshrc`).

### Home manager

Get into an Home manager shell with:

```sh
nix shell nixpkgs#home-manager --extra-experimental-features nix-command
--extra-experimental-features flakes
```

and then install the configurations:

```sh
home-manager switch --extra-experimental-features nix-command
--extra-experimental-features flakes --flake ~/.config/nixpkgs#myHomeConfig
```

(of course it doesn't have to live in `~/.config/nixpkgs`, and another commond location
would be `~/.config/home-manager`).
