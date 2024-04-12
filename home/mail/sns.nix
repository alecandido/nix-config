{
  config,
  inputs,
  ...
}: {
  age.secrets.mail-sns.file = inputs.secrets.mail-sns;

  accounts.email.accounts.sns = {
    realName = "Alessandro Candido";
    address = "alessandro.candido@alumni.sns.it";
    aliases = ["alessandro.candido@sns.it"];
    userName = "candido.ale";
    flavor = "gmail.com";
    passwordCommand = "cat ${config.age.secrets.mail-sns.path}";
  };
}
