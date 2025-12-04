{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    firefox
    pdfchain
    obsidian
    spotifyd
    vesktop
    kdePackages.okular
    telegram-desktop
  ];
}
