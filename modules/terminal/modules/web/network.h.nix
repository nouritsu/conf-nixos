{lib, pkgs, ...}: let
  xh = lib.getExe pkgs.xh;
  speedtest-rs = lib.getExe pkgs.speedtest-rs;
  browsh = lib.getExe pkgs.browsh;
  wiki-tui = lib.getExe pkgs.wiki-tui;
in {
  home.packages = [
    pkgs.wiki-tui
  ];

  home.shellAliases = {
    request = xh;
    test-api = xh;
    speedtest = speedtest-rs;
    browser = "${browsh}";
    wiki = wiki-tui;
  };
}
