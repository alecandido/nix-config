{ pkgs, ... }:

{
  src = pkgs.fetchFromGitHub {
    owner = "NvChad";
    repo = "NvChad";
    rev = "refs/heads/v2.0";
    sha256 = "sha256-6O8NmVlauPuvPVv60bcwqFeS/UZJWZC1/Xr23a9GWDM=";
  };
}
