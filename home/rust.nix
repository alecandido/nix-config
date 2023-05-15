{ pkgs, ... }:

{
  home.packages = with pkgs;
    [
      cargo
    ];

  home.file.".cargo/config.toml".text = ''
    [registries.crates-io]
    protocol = "sparse"
  '';
}
