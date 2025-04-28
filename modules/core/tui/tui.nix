{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Core
    uutils-coreutils-noprefix
    jj
    jjui
    inputs.yazi.packages."${pkgs.system}".yazi
    fzf
    wget
    wl-clipboard-rs
    parted
    zoxide # cd
    eza # ls
    bat # cat
    btop # top
    dust # du
    ripgrep # grep
    poppler_utils
    ripgrep-all
    rip2 # rm
    frawk # awk
    xcp # cp
    delta # diff
    fd # find
    hexyl # xxd
    procs # ps
    xh # curl
    scooter
    sd # sed
    hyperfine # time
    speedtest-rs
    inputs.helix.packages."${pkgs.system}".helix
    starship
    eva # Calculator
    tokei
    grex
    any-nix-shell
    glow
    browsh
    nap
    ffmpeg-full
    pdftk
    clipcat
    gum
    brightnessctl
    edir

    # Documentation / Information
    navi # Cheat Sheets
    tealdeer # tldr replacement
    wiki-tui # Wikipedia

    # Internet
    spotdl
    yt-dlp
    mullvad-vpn
    mullvad-closest

    # Fun
    cowsay
    fastfetch
    cpufetch
    sl

    # NixOS
    nh
    nix-output-monitor

    # Foreign Compatability
    android-tools # Android Tooling
    ntfs3g # NTFS Support
  ];
}
