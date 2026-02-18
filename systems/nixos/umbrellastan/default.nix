{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./kanata.nix
  ];

  services.displayManager.gdm.autoSuspend = false;
}
