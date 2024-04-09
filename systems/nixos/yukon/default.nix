{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./kanata.nix
    ./networking.nix
  ];

  services.xserver.displayManager.gdm.autoSuspend = false;
}
