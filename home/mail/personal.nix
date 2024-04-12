{
  config,
  inputs,
  ...
}: {
  age.secrets.mail-personal.file = inputs.secrets.mail-personal;

  accounts.email.accounts.personal = {
    realName = "Alessandro Candido";
    address = "candido.ale@gmail.com";
    userName = "candido.ale";
    primary = true;
    flavor = "gmail.com";
    passwordCommand = "cat ${config.age.secrets.mail-personal.path}";
  };
}
