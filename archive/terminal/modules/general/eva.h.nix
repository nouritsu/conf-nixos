{
  lib,
  pkgs,
  ...
}: let
  eva = lib.getExe pkgs.eva;
in {
  home.shellAliases = rec {
    calculator = eva;
    calc = calculator;
  };
}
