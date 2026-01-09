{pkgs, ...}: let
  xh = "${pkgs.xh}/bin/xh";
  speedtest-rs = "${pkgs.speedtest-rs}/bin/speedtest-rs";
  browsh = "${pkgs.browsh}/bin/browsh";
  wiki-tui = "${pkgs.wiki-tui}/bin/wiki-tui";
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
