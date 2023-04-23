{ pkgs, lib, ... }:

{
  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      curl
      wget

      # Tools
      exa
      jq
      ripgrep
      fd
      ripgrep-all
      gh
    ] ++ lib.optionals stdenv.isDarwin [ m-cli ];
}
