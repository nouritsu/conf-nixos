{pkgs, ...}: let
  nm = "${pkgs.networkmanager}";
  nm-applet = "${nm}/bin/nm-applet";
  nm-connection-editor = "${nm}/bin/nm-connection-editor";
in {
  home.packages = [
    pkgs.networkmanager
    pkgs.networkmanager-openvpn
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    nm-applet
  ];

  # FIX: does not open
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
