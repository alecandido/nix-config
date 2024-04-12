{
  config,
  inputs,
  ...
}: {
  age.secrets.mail-cern.file = inputs.secrets.mail-cern;

  accounts.email.accounts.cern = {
    realName = "Alessandro Candido";
    address = "a.candido@cern.ch";
    aliases = ["candidalo@cern.ch" "alessandro.candido@cern.ch"];
    userName = "candidal";
    flavor = "outlook.office365.com";
    passwordCommand = "cat ${config.age.secrets.mail-cern.path}";
  };
}
