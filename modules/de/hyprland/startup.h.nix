{pkgs, ...}: let
  nm-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  blueman-applet = "${pkgs.blueman}/bin/blueman-applet";
  pasystray = "${pkgs.pasystray}/bin/pasystray";
  polkit-agent = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
in {
  wayland.windowManager.hyprland.settings.exec-once = [
    "${polkit-agent}"
    "wezterm-mux-server --daemonize" # terminal
    "${nm-applet}"
    "${blueman-applet}"
    "${pasystray}"
    "vesktop --start-minimized" # discord
    "steam -silent" # i don't write useless comments, no
  ];
}
