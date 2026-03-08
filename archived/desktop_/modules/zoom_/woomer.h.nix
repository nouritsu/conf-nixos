{
  lib,
  pkgs,
  ...
}: let
  woomer = lib.getExe pkgs.woomer;
in {
  home.packages = [
    pkgs.woomer
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, Z, exec, ${woomer}"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:title woomer";
  in [
    "no_anim on, ${match_}"
    "immediate on, ${match_}"
  ];
}
