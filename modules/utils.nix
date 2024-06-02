{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alejandra
    android-tools
    bat
    btop
    cowsay
    detox
    dust
    fzf
    gparted
    jq
    lsd
    nerdfetch
    nixfmt-classic
    pomodoro
    ripgrep
    ripgrep-all
    sl
    speedtest-rs
    spotdl
    tealdeer
    wget
    wiki-tui
    youtube-dl
  ];
}
