{
  lib,
  pkgs,
  ...
}: let
  navi = lib.getExe pkgs.navi;
in {
  home.packages = [
    pkgs.tealdeer
    pkgs.navi
  ];

  home.shellAliases = rec {
    cheat = navi;
    cheatsheet = cheat;
  };

  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
