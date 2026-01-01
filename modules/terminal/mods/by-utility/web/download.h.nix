{pkgs, ...}: let
  wget2 = "${pkgs.wget2}/bin/wget";
  axel = "${pkgs.axel}/bin/axel";
  yt-dlp = "${pkgs.yt-dlp}/bin/yt-dlp";
  spotdl = "${pkgs.spotdl}/bin/spotdl";
in {
  home.packages = [
    pkgs.wget # usable with `command wget`
  ];

  home.shellAliases = rec {
    wget = wget2;
    download = axel;

    download-youtube = yt-dlp;
    download-yt = download-youtube;
    download-spotify = spotdl;
    download-spot = download-spotify;
  };
}
