{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.interfaces."eno1".wakeOnLan = {
    enable = true;
    policy = ["magic" "phy"];
  };
}
