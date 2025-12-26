{pkgs, ...}: {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    nerd-fonts.blex-mono
    nerd-fonts.fira-code
    nerd-fonts.lilex
    meslo-lgs-nf
    mplus-outline-fonts.githubRelease
  ];
}
