{
  lib,
  pkgs,
  ...
}: let
  wget = lib.getExe' pkgs.wget2 "wget";
  axel = lib.getExe pkgs.axel;
  yt-dlp = lib.getExe pkgs.yt-dlp;
  spotdl = lib.getExe pkgs.spotdl;
in {
  home.packages = [
    pkgs.wget # usable with `command wget`
  ];

  home.shellAliases = rec {
    inherit wget;
    download = axel;

    download-youtube = yt-dlp;
    download-yt = download-youtube;
    download-spotify = spotdl;
    download-spot = download-spotify;
  };
}
