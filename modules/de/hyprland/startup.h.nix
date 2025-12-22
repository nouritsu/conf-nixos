{...}: {
  wayland.windowManager.hyprland.settings.exec-once = [
    "wezterm-mux-server --daemonize" # terminal
    "nm-applet"
    "blueman-applet"
    "vesktop --start-minimized" # discord
    "steam -silent" # i don't write useless comments, no
  ];
}
