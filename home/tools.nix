{ pkgs, lib, ... }:

{
  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      curl
      wget

      # Tools
      exa
      jq
      ripgrep
      fd
      ripgrep-all
      duf
      gh
      ncdu
      fzf
    ] ++ lib.optionals stdenv.isDarwin [ m-cli ];

  # XDG
  xdg.enable = true;

  # Starship
  programs.starship = {
    enable = true;
    settings = { hostname.ssh_only = false; package.disabled = true; };
  };

  # Zellij
  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
      default_layout = "compact";
      theme = "nord";
      themes = {
        nord = {
          fg = [ 216 222 233 ]; #D8DEE9
          bg = [ 46 52 64 ]; #2E3440
          black = [ 59 66 82 ]; #3B4252
          red = [ 191 97 106 ]; #BF616A
          green = [ 163 190 140 ]; #A3BE8C
          yellow = [ 235 203 139 ]; #EBCB8B
          blue = [ 129 161 193 ]; #81A1C1
          magenta = [ 180 142 173 ]; #B48EAD
          cyan = [ 136 192 208 ]; #88C0D0
          white = [ 229 233 240 ]; #E5E9F0
          orange = [ 208 135 112 ]; #D08770
        };
      };
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
}
