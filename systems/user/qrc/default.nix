{pkgs, ...}: {
  # Standalone Nix on a foreign (non-NixOS) distro, no admin privileges.
  targets.genericLinux.enable = true;

  home.homeDirectory = "/home/users/alessandro.candido";
  home.sessionPath = ["$HOME/.nix-profile/etc/profile.d/nix.sh"];

  nix.package = pkgs.nix;
}
