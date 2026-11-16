{pkgs, ...}: {
  home.packages = [
    (
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.callPackage ../lib/remote-apps/xpra-macos.nix {}
      else pkgs.xpra
    )
  ];

  programs.ssh.settings.rose-oasis = {
    hostname = "rose-oasis";
    user = "alessandro";
  };
}
