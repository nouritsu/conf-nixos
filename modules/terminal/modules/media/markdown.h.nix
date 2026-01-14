{
  lib,
  pkgs,
  ...
}: let
  glow = lib.getExe pkgs.glow;
in {
  home.shellAliases = {
    view-md = "${glow}";
  };
}
