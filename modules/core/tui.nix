{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Core
    uutils-coreutils-noprefix
    yazi
    detox
    fzf
    wget
    parted
    eza # ls
    bat # cat
    btop # top
    dust # du
    ripgrep # grep
    ripgrep-all
    rip2 # rm
    frawk # awk
    xcp # cp
    delta # diff
    fd # find
    hexyl # xxd
    xh # curl
    hyperfine # time
    speedtest-rs
    helix
    starship
    eva # Calculator
    lazygit
    gh
    git

    # Shells
    bash
    fish

    # Documentation / Information
    navi # Cheat Sheets
    tealdeer # tldr replacement
    wiki-tui # Wikipedia

    # Internet
    spotdl
    yt-dlp

    # Fun
    cowsay
    fastfetch
    cpufetch
    sl

    # Nix
    nh

    # Foreign Compatability
    android-tools # Android Tooling
    ntfs3g # NTFS Support
  ];
}
