# Shut down to avoid a noisy machine running during office hours
{
  systemd.services.silence = {
    enable = true;
    description = "Shut down klondike during office hours.";
    serviceConfig = {
      ExecStart = "shutdown now";
    };
    startAt = "08:00";
  };
}
