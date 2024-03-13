# Shut down to avoid a noisy machine running during office hours
{
  systemd.services.shutdown = {
    enable = true;
    wantedBy = ["multi-user.target"];
    description = "Shut down klondike during office hours.";
    serviceConfig = {
      ExecStart = "sudo shutdown now";
    };
    startAt = "*:00/10:00"; # every minute
  };
}
