{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Internet
    google-chrome
    mailspring

    # Socials
    discord
    skypeforlinux
    telegram-desktop

    # Media
    obs-studio
    spotify
    vlc

    # Miscellanous
    obsidian
  ];
}
