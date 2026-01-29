{
  inputs,
  lib,
  pkgs,
  ...
}: let
  walker = lib.getExe pkgs.walker;
in {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, SUPER_L, exec, ${walker}"
  ];

  wayland.windowManager.hyprland.settings.layerrule = let
    match_ = "match:namespace walker";
  in [
    "no_anim on, ${match_}"
  ];
}
