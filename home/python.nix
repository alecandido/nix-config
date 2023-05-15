{ pkgs, ... }:

{
  home.packages = with pkgs;
    [
      python311
      black
      poetry
      pre-commit
    ];
}
