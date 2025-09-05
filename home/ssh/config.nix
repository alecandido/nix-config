{
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
    qrc =
      extend
      {
        user = "alessandro.candido";
      };
    scqt =
      extend
      {
        proxyJump = "zeraa";
        extraOptions = {
          RemoteCommand = "PowerShell";
        };
      };
  in {
    "bastione" = {
      hostname = "bastione.mi.infn.it";
      user = "acandido";
    };
    "dom" = {
      hostname = "dom.mi.infn.it";
      user = "alessandro";
      proxyJump = "bastione";
    };
    "qrc" = qrc {
      hostname = "login.qrccluster.com";
    };
    "qrcfromlab" = qrc {
      hostname = "192.168.2.66";
    };
    "qrcws" = qrc {
      hostname = "workspace";
      proxyJump = "qrc";
    };
    "zeraa" = qrc {
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
    "lxplus*" = {
      user = "candidal";
      extraOptions = {
        GSSAPITrustDns = "yes";
        GSSAPIAuthentication = "yes";
        GSSAPIDelegateCredentials = "yes";
        AddKeysToAgent = "yes";
        StrictHostKeyChecking = "False";
        ChallengeResponseAuthentication = "no";
      };
    };
    "lxplus" = {
      hostname = "lxplus9.cern.ch";
    };
    "villarose" = personal {
      hostname = "villarose.annibale.dev";
    };
    "yukon" = personal {
      hostname = "localhost";
      port = 22001;
      proxyJump = "villarose";
    };
    "klondike" = personal {
      hostname = "ac-klondike";
      proxyJump = "yukon";
    };
    "killmotor" = personal {
      hostname = "localhost";
      port = 22003;
      proxyJump = "villarose";
    };
  };
}
