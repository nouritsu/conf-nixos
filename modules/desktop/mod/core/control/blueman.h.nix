{pkgs, ...}: let
  blueman-applet = "${pkgs.blueman}/bin/blueman-applet";
in {
  home.packages = [
    pkgs.blueman
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    blueman-applet
  ];
}
