{...}: {
  environment.systemPackages = with pkgs; [
    warp-terminal
    google-chrome
    libreoffice-fresh
    pdfchain
    obsidian
    spotifyd
    vesktop
  ];
}
