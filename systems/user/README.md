# User configurations

Purely home manager configurations, to use Nix on an OS different from NixOS and
nix-darwin.

- `qrc`: personal machine with no admin/root access. Activate with
  `nh home switch -c qrc` (or plain `nh home switch` when
  run as `alessandro.candido` on host `qrc`, since `nh` resolves
  `homeConfigurations."$USER@$(hostname)"` by default).
