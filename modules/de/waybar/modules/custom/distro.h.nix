{pkgs, ...}: let
  wleave = "${pkgs.wleave}/bin/wleave -x";
in {
  programs.waybar.settings.default."custom/distro" = {
    format = "";
    on-click = wleave;
    tooltip = false;
  };
}
