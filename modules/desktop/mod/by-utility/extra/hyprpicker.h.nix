{pkgs, ...}: let
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
in {
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, C, exec, ${hyprpicker} --autocopy --lowercase-hex"
  ];

  wayland.windowManager.hyprland.settings.layerrule = [
    "no_anim on, match:namespace hyprpicker"
  ];
}
