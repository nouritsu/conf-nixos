{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    warp-terminal
    google-chrome
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
