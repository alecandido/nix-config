{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [krb5];

  xdg.configFile."kerberos/krb5.conf".source = ./krb5.conf;
  home.sessionVariables = {
    KRB5_CONFIG = "${config.xdg.configHome}/kerberos/krb5.conf";
  };
}
