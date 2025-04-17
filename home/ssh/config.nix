{
  programs.ssh.matchBlocks = let
    # FIXME: better using OpenSSH tags, but this is limited by the home-manager
    # support:
    # multiple 'Tag' directives would be allowed, but since it is not a natively
    # supported one, it should be provided withing `extraOptions`, which instead is an
    # attribute set of directives, restricting to a single tag
    # thus, using Nix results in more flexible compositions - at the possible price of
    # a larger generated output (since fully expanded)
    personal = cfg:
      {
        user = "alessandro";
        forwardAgent = true;
      }
      // cfg;
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
    "qrc*" = {
      user = "alessandro.candido";
    };
    "qrccluster" = {
      hostname = "login.qrccluster.com";
    };
    "qrcfromlab" = {
      hostname = "192.168.2.66";
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
