{config, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./kanata.nix
  ];

  plan.apps = {
    zoom.enable = true;
    teams.enable = true;
    spotify.enable = true;
  };

  # TP-Link Archer T2UB Nano Wi-Fi driver
  boot.extraModulePackages = [config.boot.kernelPackages.rtl8821cu];
  boot.kernelModules = ["8821cu"];
  boot.blacklistedKernelModules = ["rtw88_8821cu" "rtl8xxxu"];
}
