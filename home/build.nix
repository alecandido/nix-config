{pkgs, ...}: {
  home.packages = with pkgs; [
    gnumake
    gcc
  ];

  xdg.configFile."gdb/gdbinit".text = ''
    set history save
    tui enable
    # TODO: remove the following
    set auto-load safe-path /

    define hook-next
      refresh
    end

    define hook-step
      refresh
    end

    define hook-continue
      refresh
    end
  '';
}
