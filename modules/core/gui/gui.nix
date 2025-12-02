{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    firefox
    pdfchain
    obsidian
    spotifyd
    vesktop
    kitty
    libsForQt5.okular
    telegram-desktop
    arduino-ide
  ];
}
