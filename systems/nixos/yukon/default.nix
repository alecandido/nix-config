{lib, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./kanata.nix
    ./networking.nix
  ];

  services.udev.extraRules = lib.mkAfter ''
    # CMSIS-DAP for microbit
    SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", MODE:="666"
  '';
}
