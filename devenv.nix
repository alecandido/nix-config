{
  pkgs,
  lib,
  ...
}:
{
  packages =
    with pkgs;
    [
      alejandra
      deadnix
      skopeo
      jq
      prek
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      apptainer
    ];

  languages.nix.enable = true;

  # Define scripts directly in devenv
  scripts.format.exec = "nix fmt .";

  scripts.build-qrc-oci.exec = ''
    echo "Building QRC OCI container..."
    nix build \
      --expr 'let pkgs = (import <nixpkgs> {}); in (import ./systems/user/containers.nix {inherit pkgs;}).qrc-oci' \
      --out-link result-oci
    echo "OCI container: result-oci/docker-image-qrc.tar.gz"
  '';

  scripts.build-qrc-apptainer = lib.mkIf pkgs.stdenv.isLinux {
    exec = ''
      echo "Building QRC Apptainer definition..."
      def=$(nix build \
        --expr 'let pkgs = (import <nixpkgs> {}); in (import ./systems/user/containers.nix {inherit pkgs;}).qrc-apptainer-def' \
        --no-link --json | ${pkgs.jq}/bin/jq -r '.[0].outputs.out')
      ${pkgs.apptainer}/bin/apptainer build qrc.sif "$def"
      echo "Apptainer container: qrc.sif"
    '';
  };

  scripts.build-qrc-container.exec = ''
    type=''${1:-oci}
    case $type in
      oci)
        build-qrc-oci
        ;;
      apptainer)
        if command -v build-qrc-apptainer >/dev/null 2>&1; then
          build-qrc-apptainer
        else
          echo "Apptainer is not available on macOS (Linux only)." >&2
          exit 1
        fi
        ;;
      both)
        echo "Building both OCI and Apptainer containers..."
        build-qrc-oci
        if command -v build-qrc-apptainer >/dev/null 2>&1; then
          build-qrc-apptainer
        else
          echo "Skipping Apptainer: not available on macOS (Linux only)." >&2
        fi
        ;;
      *)
        echo "Usage: $0 [oci|apptainer|both]"
        exit 1
        ;;
    esac
  '';
}
