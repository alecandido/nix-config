{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.plan.teams.enable && config.plan.niri.enable) {
    plan.niri.extraConfig = lib.mkAfter (builtins.readFile ./niri.kdl);
  };
}
