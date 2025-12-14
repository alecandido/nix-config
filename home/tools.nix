{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      killall
      curl
      wget

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
      # delta # https://github.com/NixOS/nixpkgs/pull/334814
      just
      jc

      # Network
      dnsutils
      ldns
      dogdns
      socat
      nmap
      mtr
      wakeonlan

      # Node JS
      # mainly to support some neovim plugins...
      # slim = no NPM
      nodejs-slim_22

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

  # common variables
  home.sessionVariables = {
    # default programs
    BROWSER =
      if !pkgs.stdenv.isDarwin
      then "${config.programs.firefox.package}/bin/firefox"
      else "/Applications/Firefox.app/Contents/MacOS/firefox";
    EDITOR = lib.mkForce "${config.programs.neovim.package}/bin/nvim";
    MANPAGER = "${config.programs.neovim.package}/bin/nvim +Man!";
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
    # TODO: disable until the zoxide nushell init patch will be available
    enableNushellIntegration = false;
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
  # programs.rbw = {
  #   enable = true;
  #   settings.email = "candido.ale@gmail.com";
  # };

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
    themeFile = "Nord";
  };

  # Broot
  programs.broot.enable = true;

  # Nix helper
  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  # Ghostty
  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    enableBashIntegration = true;
    settings = {
      # https://ghostty.org/docs/help/terminfo
      shell-integration-features = "ssh-terminfo,ssh-env";
    };
  };
}
