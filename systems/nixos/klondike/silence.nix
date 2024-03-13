# Shut down to avoid a noisy machine running during office hours
{pkgs, ...}: {
  systemd.services.silence = {
    enable = true;
    description = "Shut down klondike during office hours.";
    serviceConfig = {
      # ExecStart = "shutdown now";
      ExecStart = "${pkgs.coreutils}/bin/date";
    };
    startAt = "08:00";
  };
}
