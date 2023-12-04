{ pkgs
, lib
, ...
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
      # ripgrep-all
      duf
      gh
      ncdu_1
      fzf
      btop
      tldr
      cheat
    ]
    ++ lib.optionals stdenv.isDarwin [ m-cli ];

  # XDG
  xdg.enable = true;

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
  };
}
