{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./wifi.nix
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Early KMS for AMD RDNA integrated graphics
  boot.initrd.kernelModules = ["amdgpu"];

  # Graphics and 32-bit driver compatibility
  hardware.graphics.enable32Bit = true;

  hardware.cpu.amd.updateMicrocode = true;
  services.fstrim.enable = true;
  zramSwap.enable = true;

  users.users.alessandro.extraGroups = [
    "audio"
    "i2c"
    "video"
  ];

  # Ensures binary blobs for Wi-Fi, Bluetooth, and GPU are present
  hardware.enableRedistributableFirmware = true;
}
