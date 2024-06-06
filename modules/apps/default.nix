{ pkgs, ... }: {
  imports = [ ./neovim.nix ./steam.nix ./zsh.nix ];

  environment.systemPackages = with pkgs; [
    # ================================================================ #
    # =                           DESKTOP                            = #
    # ================================================================ #

    # Internet
    google-chrome
    mailspring

    # Communication
    vesktop
    skypeforlinux
    teams-for-linux

    # Media
    obs-studio
    spotify
    vlc

    # Graphics
    blender
    inkscape

    # Productivity
    obsidian
    drawio

    # ================================================================ #
    # =                          DEVELOPMENT                         = #
    # ================================================================ #

    # Common
    gh
    lazygit
    postman
    vscode

    # C/C++
    gcc
    clang

    # Python
    python3

    # Rust
    rustup
    bacon
    pest-ide-tools

    # JavaScript
    nodejs_22
    bun

    # Go
    go

    # ================================================================ #
    # =                           UTILITIES                          = #
    # ================================================================ #

    alejandra
    android-tools
    bat
    btop
    coreutils
    cowsay
    detox
    dust
    fzf
    gparted
    home-manager
    jq
    lsd
    nerdfetch
    nh
    nixfmt-classic
    ntfs3g
    nurl
    parted
    polychromatic
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
