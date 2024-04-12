{
  config,
  toggles,
  ...
}: let
  enableTb = builtins.elem "thunderbird" toggles;
  user = config.home.username;
in {
  imports = [
    ./personal.nix
    ./sns.nix
    ./cern.nix
  ];

  programs.thunderbird =
    if enableTb
    then {
      enable = true;
      profiles.${user} = {
        isDefault = true;
      };
    }
    else {};
}
