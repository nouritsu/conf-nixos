{
  lib,
  pkgs,
  ...
}: let
  brightnessctl = lib.getExe pkgs.brightnessctl;
in {
  wayland.windowManager.hyprland.settings.bind = [
    ",XF86MonBrightnessUp, exec, ${brightnessctl} s 5%+"
    ",XF86MonBrightnessDown, exec, ${brightnessctl} s 5%-"
  ];
}
