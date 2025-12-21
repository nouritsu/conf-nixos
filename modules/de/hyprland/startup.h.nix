{...}: {
  wayland.windowManager.hyprland.settings.exec-once = [
    "wezterm-mux-server --daemonize" # terminal
    "vesktop --start-minimized" # discord
    "steam -silent" # i don't write useless comments, no
  ];
}
