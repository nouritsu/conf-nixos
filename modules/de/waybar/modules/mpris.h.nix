{...}: {
  programs.waybar.settings.default.mpris = {
    format = "{icon}{title} - {artist}";
    format-paused = "{icon}{title} - {artist}";
    tooltip-format = "Playing: {title} - {artist}";
    tooltip-format-paused = "Paused: {title} - {artist}";
    player-icons.default = " ";
    status-icons.default = " ";
    max-length = 1000;
  };
}
