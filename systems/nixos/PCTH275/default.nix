{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  services.xserver.displayManager.gdm.autoSuspend = false;
}
