{pkgs, ...}: let
  nm-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
in {
  home.packages = [
    pkgs.networkmanager
    pkgs.networkmanager-openvpn
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    nm-applet
  ];
}
