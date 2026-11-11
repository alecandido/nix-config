{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.amd.updateMicrocode = true;
  services.fstrim.enable = true;
  networking.networkmanager.wifi.powersave = false;

  users.users.alessandro.extraGroups = [
    "audio"
    "video"
  ];
}
