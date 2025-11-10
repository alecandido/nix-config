{lib, ...}: {
  programs.ssh.matchBlocks = let
    # FIXME: better using OpenSSH tags, but this is limited by the home-manager
    # support:
    # multiple 'Tag' directives would be allowed, but since it is not a natively
    # supported one, it should be provided within `extraOptions`, which instead is an
    # attribute set of directives, restricting to a single tag
    # thus, using Nix results in more flexible compositions - at the possible price of
    # a larger generated output (since fully expanded)
    extend = args: cfg: args // cfg;
    personal =
      extend
      {
        user = "alessandro";
        forwardAgent = true;
      };
    fullname = extend {
      user = "alessandro.candido";
    };
    scqt =
      extend
      {
        proxyJump = "qrc-zeraa";
        # FIXME: for some reason, when specified as remote command it prevents shortcuts
        # extraOptions = {
        #   RemoteCommand = "PowerShell";
        # };
      };
    # for each config, generate two copies: the bare one, and the `-fromlab` version,
    # which create two separate hierarchies, one starting from the login node with
    # domain name, the other with the IP address, for use within the lab
    qrc = cfgs: (
      lib.attrsets.mergeAttrsList
      (
        lib.attrsets.mapAttrsToList (name: cfg: {
          "qrc-${name}" = cfg;
          "qrc-${name}-fromlab" = cfg // {proxyJump = cfg.proxyJump + "-fromlab";};
        })
        cfgs
      )
    );
  in
    {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      "bastione" = {
        hostname = "bastione.mi.infn.it";
        user = "acandido";
      };
      "dom" = {
        hostname = "dom.mi.infn.it";
        user = "alessandro";
        proxyJump = "bastione";
      };
      "yukon" = personal {
        hostname = "2.229.167.187";
        port = 2222;
      };
      "qrc" = fullname {
        hostname = "login.qrccluster.com";
      };
      "qrc-fromlab" = fullname {
        hostname = "192.168.2.66";
      };
    }
    // (qrc {
      "ws" = fullname {
        hostname = "workspace";
        proxyJump = "qrc";
      };
      "zeraa" = fullname {
        hostname = "192.168.2.73";
        proxyJump = "qrc";
      };
      "scqt-iqm5q" = scqt {
        hostname = "192.168.0.221";
        user = "LENOVO";
      };
      "scqt-qw5q" = scqt {
        hostname = "192.168.0.231";
        user = "tii_s";
      };
    });
}
