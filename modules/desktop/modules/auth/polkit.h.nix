{pkgs, ...}: let
  polkit-agent = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
in {
  home.packages = [
    pkgs.polkit_gnome
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    polkit-agent
  ];
}
