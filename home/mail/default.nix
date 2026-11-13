{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.plan.mail;
  personalFile = cfg.secrets.personal;
  workFile = cfg.secrets.work;
  oauth = import ./oauth.nix {inherit config lib pkgs;};
  folders = {
    personal = {
      inbox = "INBOX";
      sent = "[Gmail]/Sent Mail";
      drafts = "[Gmail]/Drafts";
      trash = "[Gmail]/Trash";
      archive = "[Gmail]/All Mail";
    };
    work = {
      inbox = "INBOX";
      sent = "Sent Items";
      drafts = "Drafts";
      trash = "Deleted Items";
      archive = "Archive";
    };
  };
  account = name: address: {
    inherit address;
    realName = "Alessandro Candido";
    userName = address;
    maildir.path = name;
    folders = builtins.removeAttrs folders.${name} ["archive"];
    mbsync = {
      enable = true;
      create = "maildir";
      expunge = "both";
      remove = "none";
      patterns = ["*"];
      extraConfig.account.AuthMechs =
        if name == "work"
        then "XOAUTH2"
        else "PLAIN";
    };
    msmtp = {
      enable = true;
      extraConfig = {
        auth =
          if name == "work"
          then "xoauth2"
          else "plain";
        syslog = "LOG_MAIL";
      };
    };
    aerc = {
      enable = true;
      extraAccounts = {
        outgoing = "${pkgs.msmtp}/bin/msmtp --account=${name} --read-envelope-from --read-recipients";
        archive = folders.${name}.archive;
        "check-mail" = "0";
      };
      extraBinds = {
        messages = {
          d = ":move '${folders.${name}.trash}'<Enter>";
          a = ":move '${folders.${name}.archive}'<Enter>";
        };
        view = {
          d = ":move '${folders.${name}.trash}'<Enter>";
          a = ":move '${folders.${name}.archive}'<Enter>";
        };
      };
      extraConfig.ui."tab-title-account" = "{{.Account}} | {{.Folder}}";
    };
    thunderbird = {
      enable = true;
      profiles = ["mail"];
      settings = id:
        {
          "mail.server.server_${id}.name" =
            if name == "work"
            then "Work - TII"
            else "Personal - Gmail";
          "mail.server.server_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.server.server_${id}.check_new_mail" = true;
          "mail.server.server_${id}.check_time" = 5;
          "mail.server.server_${id}.trash_folder_name" = folders.${name}.trash;
        }
        // lib.optionalAttrs (name == "work" && cfg.work.thunderbirdOAuthOverride) (
          lib.foldl' lib.recursiveUpdate {} (map (prefix:
            lib.mapAttrs' (key: value: lib.nameValuePair "${prefix}.oauth2.${key}" value) {
              useCustomDetails = true;
              issuer = "entra-${cfg.work.tenant_id}-${cfg.work.client_id}";
              scopes = "https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/SMTP.Send offline_access";
              clientId = cfg.work.client_id;
              authorizationEndpoint = "https://login.microsoftonline.com/${cfg.work.tenant_id}/oauth2/v2.0/authorize";
              tokenEndpoint = "https://login.microsoftonline.com/${cfg.work.tenant_id}/oauth2/v2.0/token";
              redirectionEndpoint = "http://localhost";
              usePKCE = true;
              useExternalBrowser = true;
            }) ["mail.server.server_${id}" "mail.smtpserver.smtp_${id}"])
        );
      perIdentitySettings = id: let
        serverId = builtins.hashString "sha256" name;
        uri = "imap://${lib.escapeURL address}@${config.accounts.email.accounts.${name}.imap.host}";
        folderUri = folder: "${uri}/${lib.concatMapStringsSep "/" lib.escapeURL (lib.splitString "/" folder)}";
      in {
        "mail.identity.id_${id}.label" =
          if name == "work"
          then "Work - TII"
          else "Personal - Gmail";
        "mail.identity.id_${id}.fcc_folder" = folderUri folders.${name}.sent;
        "mail.identity.id_${id}.draft_folder" = folderUri folders.${name}.drafts;
        "mail.identity.id_${id}.archive_folder" = folderUri folders.${name}.archive;
        "mail.identity.id_${id}.archive_granularity" = 0;
        "mail.identity.id_${id}.smtpServer" = "smtp_${serverId}";
        "mail.identity.id_${id}.fcc" = name != "personal";
      };
    };
  };
in {
  options.plan.mail = {
    enable = lib.mkEnableOption "isolated Thunderbird and aerc mail clients";
    systemSecrets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      internal = true;
      description = "Use mail secrets decrypted by the NixOS host-key agenix module.";
    };
    secrets = {
      personal = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.secrets}/mail-personal.age";
        description = "Encrypted Gmail App Password file.";
      };
      work = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.secrets}/mail-work-oauth.json.age";
        description = "Encrypted Microsoft OAuth client JSON file.";
      };
    };
    credentialsReady = lib.mkOption {
      type = lib.types.bool;
      default = builtins.pathExists personalFile && builtins.pathExists workFile;
      description = "Decrypt mail secrets and enable the sync timer once both encrypted files are available.";
    };
    sync.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run background sync after mail credentials are provisioned.";
    };
    work = {
      address = lib.mkOption {
        type = lib.types.str;
        description = "Microsoft 365 email address.";
      };
      client_id = lib.mkOption {
        type = lib.types.str;
        default = "9e5f94bc-e8a4-4e73-b8be-63364c29d753";
        description = "Public Entra client ID for oama; the encrypted JSON can override it.";
      };
      tenant_id = lib.mkOption {
        type = lib.types.str;
        default = "organizations";
        description = "Entra tenant ID or verified domain for oama; the encrypted JSON can override it.";
      };
      thunderbirdOAuthOverride = lib.mkEnableOption "Thunderbird's custom public OAuth provider using the module client_id and tenant_id";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "plan.mail" pkgs lib.platforms.linux)
      {
        assertion = !cfg.credentialsReady || (builtins.pathExists personalFile && builtins.pathExists workFile);
        message = "Mail credentialsReady requires mail-personal.age and mail-work-oauth.json.age in inputs.secrets.";
      }
    ];
    warnings = lib.optional (!cfg.credentialsReady) "Mail clients are configured, but secret activation and the mbsync timer are disabled until the mail .age files are provisioned in inputs.secrets.";

    age.secrets = {
      mail-personal = {
        file = personalFile;
        enable = cfg.credentialsReady && !cfg.systemSecrets;
      };
      mail-work-oauth = {
        file = workFile;
        enable = cfg.credentialsReady && !cfg.systemSecrets;
      };
    };

    accounts.email = {
      maildirBasePath = "${config.xdg.dataHome}/mail";
      accounts = {
        personal = lib.recursiveUpdate (account "personal" "candido.ale@gmail.com") {
          primary = true;
          flavor = "gmail.com";
          passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.mail-personal.path}";
          imap = {
            host = "imap.gmail.com";
            port = 993;
          };
          smtp = {
            host = "smtp.gmail.com";
            port = 465;
            tls.useStartTls = false;
          };
          aerc.extraAccounts."copy-to" = "";
        };
        work = lib.recursiveUpdate (account "work" cfg.work.address) {
          flavor = "outlook.office365.com";
          passwordCommand = "${lib.getExe oauth} access ${lib.escapeShellArg cfg.work.address}";
          imap = {
            host = "outlook.office365.com";
            port = 993;
            authentication = "xoauth2";
          };
          smtp = {
            host = "smtp.office365.com";
            port = 587;
            authentication = "xoauth2";
            tls.useStartTls = true;
          };
        };
      };
    };

    home.packages = [oauth pkgs.w3m];
    home.activation.mailColors = lib.hm.dag.entryAfter ["linkGeneration"] ''
      if [[ ! -e "${config.home.homeDirectory}/.thunderbird/mail/folderTree.json" ]]; then
        run ${pkgs.coreutils}/bin/install -m600 ${pkgs.writeText "mail-folder-colors.json" (builtins.toJSON {
        colors = {
          "imap://candido.ale%40gmail.com@imap.gmail.com" = "#4285f4";
          "imap://${lib.escapeURL cfg.work.address}@outlook.office365.com" = "#d93025";
        };
      })} "${config.home.homeDirectory}/.thunderbird/mail/folderTree.json"
      fi
    '';
    programs.thunderbird = {
      enable = true;
      profiles.mail = {
        isDefault = true;
        accountsOrder = ["personal" "work"];
      };
      settings = {
        "experimental.mail.ews.overrideOAuth.enabled" = cfg.work.thunderbirdOAuthOverride;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "breakpad.reportURL" = "";
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "mailnews.start_page.enabled" = false;
        "mailnews.message_display.disable_remote_image" = true;
      };
      policies = {
        DisableTelemetry = true;
        DisableFeedbackCommands = true;
      };
    };
    programs.mbsync = {
      enable = true;
      package = pkgs.isync.override {withCyrusSaslXoauth2 = true;};
    };
    programs.msmtp.enable = true;
    services.mbsync = {
      enable = cfg.credentialsReady && cfg.sync.enable;
      verbose = false;
      package = config.programs.mbsync.package;
    };
    systemd.user = lib.mkIf (cfg.credentialsReady && cfg.sync.enable) {
      timers.mbsync.Timer = {
        OnCalendar = lib.mkForce [];
        OnStartupSec = "2m";
        OnUnitActiveSec = "5m";
      };
      services.mbsync.Service = {
        UMask = "0077";
        TimeoutStartSec = "15m";
      };
    };
    programs.aerc = {
      enable = true;
      extraConfig = {
        general."unsafe-accounts-conf" = true;
        ui = {
          "sidebar-width" = 24;
          "threading-enabled" = true;
          "tab-title-account" = "{{.Account}} | {{.Folder}}";
        };
        statusline = {
          "column-left" = "[{{.Account}}] {{.Folder}} {{.StatusInfo}}";
          "column-right" = "{{.TrayInfo}}";
        };
        viewer = {
          pager = "${pkgs.less}/bin/less -R";
          alternatives = "text/plain,text/html";
        };
        filters = {
          "text/plain" = "colorize";
          "text/html" = "${pkgs.w3m}/bin/w3m -dump -T text/html -I UTF-8";
          "text/calendar" = "calendar";
        };
        openers."text/html" = "${pkgs.xdg-utils}/bin/xdg-open {}";
      };
      extraBinds = builtins.readFile ./binds.conf;
    };
  };
}
