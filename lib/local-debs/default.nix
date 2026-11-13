{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.localDebInstaller;
  runtimeLibs = with pkgs;
    [
      stdenv.cc.cc.lib
      zlib
      openssl
      glib
      gtk3
      webkitgtk_4_1
      libsoup_3
      cairo
      pango
      # Prefer librsvg's cache when both expose gdk-pixbuf loaders.cache.
      (lib.lowPrio gdk-pixbuf)
      harfbuzz
      atk
      librsvg
      libayatana-appindicator
      dbus
      libxkbcommon
      wayland
      libGL
      glib-networking
    ]
    ++ cfg.extraRuntimeLibs;
  environment = ''
    export runtime_rpath=${lib.escapeShellArg (lib.makeLibraryPath runtimeLibs)}
    export dynamic_linker=${lib.escapeShellArg pkgs.stdenv.cc.bintools.dynamicLinker}
    export gio_modules=${lib.escapeShellArg "${pkgs.glib-networking}/lib/gio/modules"}
    export schema_dirs=${lib.escapeShellArg (lib.concatStringsSep ":" [
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.glib}/share"
    ])}
    export wrapper_shell=${lib.escapeShellArg "${pkgs.bash}/bin/bash"}
    export desktop_helper=${pkgs.writeText "local-deb-desktop.py" (builtins.readFile ./desktop.py)}
    export archive_helper=${pkgs.writeText "local-deb-archive.py" (builtins.readFile ./archive.py)}
    export shebang_helper=${pkgs.writeText "local-deb-shebangs.py" (builtins.readFile ./shebangs.py)}
    export shebang_path=${lib.escapeShellArg (lib.makeBinPath ([pkgs.bash pkgs.coreutils pkgs.python3] ++ runtimeLibs))}
  '';
  application = name: file:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [coreutils findutils gnugrep util-linux dpkg patchelf binutils jq python3];
      text = environment + builtins.readFile ./common.sh + builtins.readFile file;
    };
  install = application "install-local-deb" ./install.sh;
  list = application "list-local-debs" ./list.sh;
  uninstall = application "uninstall-local-deb" ./uninstall.sh;
  watcher = pkgs.writeShellScript "watch-local-debs" ''
    export PATH=${lib.makeBinPath [pkgs.coreutils]}
    umask 077
    inbox="$HOME/.local/share/private-debs"
    for directory in "$HOME/.local" "$HOME/.local/share" "$inbox" "$inbox/installed" "$inbox/failed"; do
      if [[ -L "$directory" || ( -e "$directory" && ! -O "$directory" ) ]]; then
        echo "Unsafe private-debs directory" >&2
        exit 1
      fi
      mkdir -p "$directory"
      if [[ "$directory" == "$inbox"* ]]; then
        chmod 700 "$directory"
      fi
    done
    # Keep package-specific diagnostics out of the systemd journal.
    if [[ -L "$inbox/watcher.log" ]]; then
      echo "Unsafe private-debs log" >&2
      exit 1
    fi
    exec >> "$inbox/watcher.log" 2>&1
    chmod 600 "$inbox/watcher.log"
    shopt -s nullglob
    while true; do
      for deb in "$inbox"/*.deb; do
        [[ -f "$deb" && ! -L "$deb" ]] || continue
        chmod 600 "$deb"
        # Do not unpack files which are still being copied into the inbox.
        before="$(stat -c '%s:%Y' "$deb")"
        sleep 2
        [[ -f "$deb" ]] || continue
        [[ "$before" == "$(stat -c '%s:%Y' "$deb")" ]] || continue
        destination=installed
        if ! ${lib.getExe install} "$deb"; then
          destination=failed
        fi
        target="$(mktemp "$inbox/$destination/XXXXXXXX.deb")"
        mv -- "$deb" "$target"
        chmod 600 "$target"
      done
      sleep 5
    done
  '';
in {
  options.programs.localDebInstaller = {
    enable = lib.mkEnableOption "private, runtime-only installation of local Debian packages";
    extraRuntimeLibs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional runtime libraries retained in the Home Manager profile and used in private ELF RPATHs.";
    };
    watchDirectory.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically install local debs dropped into ~/.local/share/private-debs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.localDebInstaller" pkgs lib.platforms.linux)
    ];
    home.packages = [install list uninstall pkgs.gsettings-desktop-schemas] ++ runtimeLibs;
    home.sessionPath = ["$HOME/.local/bin"];
    home.activation.privateDebDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for directory in \
        "$HOME/.local" \
        "$HOME/.local/share" \
        "$HOME/.local/opt" \
        "$HOME/.local/bin" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/private-debs" \
        "$HOME/.local/share/private-debs/installed"; do
        if [[ -L "$directory" || ( -e "$directory" && ! -O "$directory" ) ]]; then
          echo "Unsafe local-deb directory" >&2
          exit 1
        fi
        run mkdir -p "$directory"
        case "$directory" in
          "$HOME/.local"|"$HOME/.local/share") ;;
          *) run chmod 700 "$directory" ;;
        esac
      done
    '';
    systemd.user.paths.local-debs = lib.mkIf cfg.watchDirectory.enable {
      Unit.Description = "Watch the private local Debian package inbox";
      Path = {
        DirectoryNotEmpty = "%h/.local/share/private-debs";
        Unit = "local-debs.service";
      };
      Install.WantedBy = ["default.target"];
    };
    systemd.user.services.local-debs = lib.mkIf cfg.watchDirectory.enable {
      Unit.Description = "Install private local Debian packages";
      Service = {
        Type = "simple";
        ExecStart = "${watcher}";
        UMask = "0077";
        NoNewPrivileges = true;
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
