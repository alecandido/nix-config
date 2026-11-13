{
  config,
  lib,
  ...
}: let
  homes = lib.filterAttrs (_: home: home.plan.mail.enable or false) config.home-manager.users;
  enabled = homes != {};
  hostKeys = map (key: key.path) config.services.openssh.hostKeys;
in {
  home-manager.sharedModules = [
    ({
      config,
      osConfig,
      ...
    }: {
      plan.mail.systemSecrets = true;
      age.secrets = lib.mkIf config.plan.mail.enable {
        mail-personal.path = osConfig.age.secrets."mail-${config.home.username}-personal".path;
        mail-work-oauth.path = osConfig.age.secrets."mail-${config.home.username}-work-oauth".path;
      };
    })
  ];

  assertions = lib.mkIf enabled [
    {
      assertion =
        config.services.openssh.enable
        && config.age.identityPaths != []
        && lib.all (path: lib.elem (toString path) hostKeys) config.age.identityPaths;
      message = "Mail activation requires agenix identities to be OpenSSH host keys, not passphrase-protected user keys.";
    }
  ];
  services.gnome.gnome-keyring.enable = lib.mkIf enabled true;
  age.secrets = lib.mkIf enabled (lib.foldl' lib.recursiveUpdate {} (lib.mapAttrsToList (user: home: {
      "mail-${user}-personal" = {
        file = home.plan.mail.secrets.personal;
        enable = home.plan.mail.credentialsReady;
        owner = user;
        group = config.users.users.${user}.group;
        mode = "0400";
      };
      "mail-${user}-work-oauth" = {
        file = home.plan.mail.secrets.work;
        enable = home.plan.mail.credentialsReady;
        owner = user;
        group = config.users.users.${user}.group;
        mode = "0400";
      };
    })
    homes));
}
