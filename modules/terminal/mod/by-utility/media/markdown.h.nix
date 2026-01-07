{pkgs, ...}: let
  glow = "${pkgs.glow}/bin/glow";
in {
  home.shellAliases = {
    view-md = "${glow}";
  };
}
