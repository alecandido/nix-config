{ pkgs, ... }:

{
  home.packages = with pkgs;
    [
      rustup
    ];

  home.file.".cargo/config.toml".text = ''
    [registries.crates-io]
    protocol = "sparse"
  '';
}
