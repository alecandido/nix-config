{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./wifi.nix
  ];

  plan.desktop = "niri";
  plan.apps = {
    zoom.enable = true;
    teams.enable = true;
    spotify.enable = true;
  };

  time.timeZone = lib.mkForce "Asia/Dubai";
  i18n.extraLocaleSettings = lib.mkForce {};

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Early KMS for AMD RDNA integrated graphics
  boot.initrd.kernelModules = ["amdgpu"];

  # Graphics and 32-bit driver compatibility
  hardware.graphics.enable32Bit = true;

  hardware.bluetooth.enable = true;

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
