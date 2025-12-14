{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.rclone = {
    enable = true;
    remotes = {
      qrc = {
        config = {
          type = "sftp";
          host = "qrc";
          user = "alessandro.candido";
        };
        secrets = {};
        mounts = {};
      };
    };
  };

  xdg.configFile."rclone/_rclone.conf".text =
    lib.mkIf pkgs.stdenv.isDarwin
    (lib.generators.toINIWithGlobalSection {} {
      globalSection = {};
      sections = {
        qrc = {
          type = "sftp";
          host = "login.qrccluster.com";
          user = "alessandro.candido";
          key_file = "${config.home.homeDirectory}/.ssh/id_ed25519";
        };
      };
    });

  home.activation.copyRcloneConfig =
    lib.mkIf pkgs.stdenv.isDarwin
    (lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] ''
      run cp \
        ${config.xdg.configHome}/rclone/_rclone.conf \
        ${config.xdg.configHome}/rclone/rclone.conf
      run chmod +w ${config.xdg.configHome}/rclone/rclone.conf
    '');
}
