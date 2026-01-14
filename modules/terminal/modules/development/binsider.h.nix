{
  pkgs,
  lib,
  ...
}: let
  binsider = lib.getExe pkgs.binsider;
in {
  home.shellAliases = rec {
    view-elf = "${binsider}";
    view-bin = view-elf;
  };
}
