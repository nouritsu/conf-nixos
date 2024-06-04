{ pkgs, ... }: {
  imports = [ ./kitty.nix ./neovim.nix ./steam.nix ./zsh.nix ./git.nix ];

  environment.systemPackages = with pkgs; [
    # ================================================================ #
    # =                           DESKTOP                            = #
    # ================================================================ #

    # Internet
    google-chrome
    mailspring

    # Social
    vesktop
    skypeforlinux

    # Media
    obs-studio
    spotify
    vlc

    # Graphics
    blender
    # davinci-resolve install this after all the tinkering because it takes fucking forever
    inkscape

    # Productivity
    obsidian
    drawio

    # ================================================================ #
    # =                          DEVELOPMENT                         = #
    # ================================================================ #

    # Common
    gh
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
    parted
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
