{pkgs, ...}: {
  home.packages = with pkgs; [
    gnumake
    gcc
  ];

  xdg.configFile."gdb/gdbinit".text = ''
    set history save
    tui enable
  '';
}
