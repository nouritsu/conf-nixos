{
  lib,
  pkgs,
  ...
}: let
  nm-applet = lib.getExe' pkgs.networkmanagerapplet "nm-applet";
  nm-connection-editor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
in {
  home.packages = [
    pkgs.networkmanager
    pkgs.networkmanager-openvpn
    pkgs.networkmanagerapplet
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    nm-applet
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, N, exec, ${nm-connection-editor}"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class nm\-connection\-editor";
  in [
    "float on, ${match_}"
    "center on, ${match_}"
    "size (monitor_w/2.5) (monitor_h/2.5), ${match_}"
  ];
}
