{lib, pkgs, ...}: let
  hexyl = lib.getExe pkgs.hexyl;
in {
  home.shellAliases = rec {
    view-bytes = hexyl;
    hexdump = view-bytes;
  };
}
