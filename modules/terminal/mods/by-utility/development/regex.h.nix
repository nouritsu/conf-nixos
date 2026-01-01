{pkgs, ...}: let
  grex = "${pkgs.grex}/bin/grex";
in {
  home.packages = [
    pkgs.grex
  ];

  home.shellAliases = {
    gen-regex = grex;
  };
}
