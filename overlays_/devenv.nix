{devenv, ...}: _: super: let
  system = super.stdenv.system;
in {
  devenv = devenv.packages.${system}.devenv;
}
