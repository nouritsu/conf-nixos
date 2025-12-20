{pkgs, ...}: {
  /*
  #h: package installed via home-manager
  */
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    # firefox #h
    pdfchain
    obsidian
    spotifyd
    vesktop
    kdePackages.okular
    telegram-desktop
    obs-studio
    nautilus
    pavucontrol
  ];
}
