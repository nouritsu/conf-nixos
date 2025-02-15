{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    speedtest-rs
    spotdl
    wiki-tui
    yt-dlp
  ];
}
