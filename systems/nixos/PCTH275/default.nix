{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services.xserver.displayManager.gdm.autoSuspend = false;
}
