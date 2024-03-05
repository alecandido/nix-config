{
  config,
  toggles,
  ...
}: let
  enableTb = builtins.elem "thunderbird" toggles;
  user = config.home.username;
in {
  programs.thunderbird =
    if enableTb
    then {
      enable = true;
      profiles.${user} = {
        isDefault = true;
      };
    }
    else {};

  accounts.email.accounts = {
    gmail = {
      realName = "Alessandro Candido";
      address = "candido.ale@gmail.com";
      userName = "candido.ale";
      primary = true;
      flavor = "gmail.com";
      # passwordCommand = "cat ${config.age.secrets.gmail.path}";
      thunderbird =
        if enableTb
        then {
          enable = true;
          profiles = ["${user}"];
        }
        else {};
    };
    sns = {
      realName = "Alessandro Candido";
      address = "alessandro.candido@alumni.sns.it";
      aliases = ["alessandro.candido@sns.it"];
      userName = "candido.ale";
      flavor = "gmail.com";
      # passwordCommand = "cat ${config.age.secrets.sns.path}";
      thunderbird =
        if enableTb
        then {
          enable = true;
          profiles = ["${user}"];
        }
        else {};
    };
    cern = {
      realName = "Alessandro Candido";
      address = "ale.candido@cern.ch";
      aliases = ["candidalo@cern.ch" "alessandro.candido@cern.ch"];
      userName = "candidal";
      flavor = "outlook.office365.com";
      # passwordCommand = "cat ${config.age.secrets.sns.path}";
      thunderbird =
        if enableTb
        then {
          enable = true;
          profiles = ["${user}"];
        }
        else {};
    };
  };
}
