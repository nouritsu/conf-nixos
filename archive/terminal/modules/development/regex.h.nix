{
  lib,
  pkgs,
  ...
}: let
  grex = lib.getExe pkgs.grex;
in {
  home.packages = [
    pkgs.grex
  ];

  home.shellAliases = {
    gen-regex = grex;
  };
}
