{
  pkgs,
  inputs,
  usrconf,
  ...
}: {
  /*
  #h: package installed via home-manager
  */
  environment.systemPackages = with pkgs; [
    # Core
    uutils-coreutils-noprefix
    killall
    inputs.yazi.packages."${usrconf.system}".yazi
    fzf
    wget
    wl-clipboard-rs
    parted
    zoxide # cd
    lsd # ls
    bat # cat
    # btop # top #h
    dust # du
    ripgrep # grep
    poppler-utils
    ripgrep-all
    rip2 # rm
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
    # inputs.helix.packages."${usrconf.system}".helix #h
    starship
    eva # Calculator
    tokei
    grex
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
  programs.nix-ld.enable = true;
}
