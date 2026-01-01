{pkgs, ...}: let
  hexyl = "${pkgs.hexyl}/bin/hexyl";
in {
  home.shellAliases = rec {
    view-bytes = hexyl;
    hexdump = view-bytes;
  };
}
