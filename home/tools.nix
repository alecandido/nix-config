{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      curl
      wget

      # Tools
      # TODO: exa is unmaintained, replace with
      # [eza](https://github.com/eza-community/eza) (not yet available in nixpkgs 23.05)
      eza
      jq
      ripgrep
      fd
      sd
      rnr
      # ripgrep-all
      duf
      gh
      ncdu_1
      fzf
      btop
      tldr
      delta

      #network
      dnsutils
      ldns
      dogdns
      socat
      nmap
      mtr
      wakeonlan

      # fonts
      fira-code-nerdfont
      meslo-lgs-nf

      #
      nodejs_21

      # system tools
      # sysstat
      # lm_sensors # for `sensors` command
      # ethtool
      pciutils # lspci
      # usbutils # lsusb
    ]
    ++ lib.optionals stdenv.isDarwin [m-cli];

  # XDG
  xdg.enable = true;

  # default programs
  home.sessionVariables = {
    BROWSER = "firefox";
    EDITOR = "nvim";
  };

  # Starship
  programs.starship = {
    enable = true;
    settings = {
      hostname.ssh_only = false;
      package.disabled = true;
    };
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      enter_accept = true;
      keymap_mode = "vim-insert";
      search_mode_shell_up_key_binding = "prefix";
      style = "compact";
      update_check = false;
    };
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Htop
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  # Bitwarden
  programs.rbw = {
    enable = true;
    settings.email = "candido.ale@gmail.com";
    package = pkgs.rbw.overrideAttrs (oldAttrs: {
      patches =
        oldAttrs.patches
        ++ [
          (
            pkgs.fetchpatch {
              name = "add-useragent.patch";
              url = "https://github.com/doy/rbw/files/14921243/patch.txt";
              sha256 = "sha256-SS+PTWA1UTsluts9Qtv+q3LJ22PTRUZ+usOB0aqz3Rk=";
            }
          )
        ];
    });
  };

  # Kitty
  programs.kitty = {
    enable = true;
    font = {
      name = "MesloLGS NF";
      size = lib.mkDefault 8;
    };
    settings = {
      hide_window_decorations = "yes";
    };
    theme = "Nord";
    shellIntegration.enableZshIntegration = true;
  };
}
