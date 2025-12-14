{pkgs, ...}: {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.blex-mono
    meslo-lgs-nf
    mplus-outline-fonts.githubRelease
  ];
}
