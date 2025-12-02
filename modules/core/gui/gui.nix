{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    firefox
    pdfchain
    obsidian
    spotifyd
    vesktop
    kitty
    kdePackages.okular
    telegram-desktop
    arduino-ide
  ];
}
