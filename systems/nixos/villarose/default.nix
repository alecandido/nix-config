{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
  ];

  powerManagement.enable = false;
}
