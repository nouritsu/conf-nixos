{pkgs, ...}: let
  blueman = "${pkgs.blueman}";
  blueman-applet = "${blueman}/bin/blueman-applet";
  blueman-manager = "${blueman}/bin/blueman-manager";
in {
  home.packages = [
    pkgs.blueman
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    blueman-applet
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, B, exec, ${blueman-manager}"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class \.blueman\-manager\-wrapped";
  in [
    "float on, ${match_}"
    "center on, ${match_}"
    "size (monitor_w/2.5) (monitor_h/2.5), ${match_}"
  ];
}
