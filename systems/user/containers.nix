# Container images for QRC
{pkgs, ...}:
let
  baseConfig = {
    Env = [
      "HOME=/home/users/alessandro.candido"
      "PATH=/home/users/alessandro.candido/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];
    WorkingDir = "/home/users/alessandro.candido";
    Cmd = ["/bin/bash"];
  };
  contents = pkgs.buildEnv {
    name = "qrc-contents";
    paths = with pkgs; [coreutils bash glibc];
  };
in
{
  qrc-oci = pkgs.dockerTools.buildImage {
    name = "qrc";
    tag = "latest";
    copyToRoot = contents;
    config = baseConfig;
  };

  qrc-apptainer-def = pkgs.writeText "qrc.def" ''
    BootStrap: docker
    From: ubuntu:22.04

    %labels
      Author AleCandido
      Version 1.0

    %environment
      export HOME=/home/users/alessandro.candido
      export PATH=/home/users/alessandro.candido/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    %post
      mkdir -p /home/users/alessandro.candido
      chmod 755 /home/users

    %runscript
      exec /bin/bash "$@"
  '';
}
