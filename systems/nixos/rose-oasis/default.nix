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

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Early KMS for AMD RDNA integrated graphics
  boot.initrd.kernelModules = ["amdgpu"];

  # Graphics and 32-bit driver compatibility
  hardware.graphics.enable32Bit = true;

  hardware.bluetooth = {
    enable = true;
    # BlueZ 5.88 fixes cached A2DP endpoints and stale connection states.
    package =
      if lib.versionOlder pkgs.bluez.version "5.88"
      then
        pkgs.bluez.overrideAttrs (old: {
          version = "5.88";
          src = pkgs.fetchurl {
            url = "https://www.kernel.org/pub/linux/bluetooth/bluez-5.88.tar.xz";
            hash = "sha256-aVLDnrX4sO5xLMUKs7z/A74XxBDdl8pkD0hJ2aFlO6M=";
          };
          # Drop the superseded upstream fix and adapt the readline build fix.
          patches =
            builtins.filter (
              patch:
                !(lib.isDerivation patch && patch.name == "fix-uuid-discovery-segfault")
                && !(lib.hasSuffix "/lreadline.patch" (toString patch))
            )
            old.patches;
          postPatch =
            old.postPatch
            + ''
              substituteInPlace Makefile.tools \
                --replace-fail '-lreadline' '$(READLINE_LIBS)'
              substituteInPlace configure.ac \
                --replace-fail 'AC_CHECK_HEADERS(readline/readline.h, enable_readline=yes,
                              AC_MSG_ERROR(readline header files are required))' \
                               'PKG_CHECK_MODULES([READLINE], [readline], enable_readline=yes)'
            '';
          # The deprecated gatttool was removed upstream in 5.88.
          postInstall = lib.replaceStrings ["install -Dm755 attrib/gatttool $out/bin/gatttool"] [""] old.postInstall;
        })
      else pkgs.bluez;
  };

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
