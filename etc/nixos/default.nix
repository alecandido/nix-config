{
  pkgs,
  options,
  ...
}: {
  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    efi.canTouchEfiVariables = true;
  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.nushell;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable firmware udpates
  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.alessandro = {
    isNormalUser = true;
    description = "Alessandro Candido";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      git
      usbutils
      wl-clipboard
      gnome-browser-connector
      # gnome-extension-manager
      gnomeExtensions.appindicator
      brave
      telegram-desktop
      fractal
      waypipe
      thunderbird
      zoom-us
      xournalpp
    ];

    shellAliases = {
      upgrade = ''
        sudo nixos-rebuild switch --flake "$HOME/Projects/nix-config" --fast --show-trace
      '';
    };

    gnome.excludePackages = with pkgs; [
      epiphany
      gnome-contacts
      gnome-maps
      gnome-music
      geary
      seahorse
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    extraConfig = ''
      Match All
        AllowAgentForwarding yes
    '';
  };

  system.stateVersion = "23.11";

  hardware.keyboard.zsa.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    mplus-outline-fonts.githubRelease
  ];

  programs.nix-ld = {
    enable = true;
    libraries = options.programs.nix-ld.libraries.default;
  };
}
