{pkgs, ...}: let
  eva = "${pkgs.eva}/bin/eva";
in {
  home.shellAliases = rec {
    calculator = eva;
    calc = calculator;
  };
}
