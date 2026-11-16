{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  mac = inputs.self.darwinConfigurations.donaldville.config.home-manager.users.alessandro;
  linux = inputs.self.nixosConfigurations.rose-oasis.config.home-manager.users.alessandro;
  ghosttyTerminfo = "/Applications/Ghostty.app/Contents/Resources/terminfo";
in
  assert mac.programs.zsh.autosuggestion.enable;
  assert !(lib.elem ghosttyTerminfo (linux.home.sessionSearchVariables.TERMINFO_DIRS or []));
    pkgs.runCommand "terminal-environment-check" {} ''
      export TERM=xterm-ghostty
      export TERMINFO_DIRS=/existing/terminfo
      unset __HM_SESS_VARS_SOURCED
      source ${pkgs.writeText "macos-session-vars.sh" mac.home.sessionVariablesPackage.text}
      [[ "$TERMINFO_DIRS" == ${ghosttyTerminfo}:* ]]
      [[ ":$TERMINFO_DIRS:" == *:/existing/terminfo:* ]]
      [[ ":$TERMINFO_DIRS:" == *:/usr/share/terminfo:* ]]
      [[ "$TERM" == xterm-ghostty ]]
      touch "$out"
    ''
