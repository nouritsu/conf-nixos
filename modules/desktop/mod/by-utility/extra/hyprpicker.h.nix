{pkgs, ...}: let
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
in {
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, C, exec, ${hyprpicker} --autocopy --lowercase-hex"
  ];
}
