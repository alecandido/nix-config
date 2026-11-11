{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.amd.updateMicrocode = true;
  services.fstrim.enable = true;

  users.users.alessandro.extraGroups = [
    "audio"
    "video"
  ];

  # Ensures binary blobs for Wi-Fi 7, Bluetooth, and GPU are present
  hardware.enableRedistributableFirmware = true;

  # Prevents NetworkManager from dropping the card into idle sleep
  networking.networkmanager.wifi.powersave = false;
}
