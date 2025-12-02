{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
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
