{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./silence.nix
  ];

  networking.interfaces."eno1".wakeOnLan = {
    enable = true;
    policy = ["magic" "phy"];
  };
}
