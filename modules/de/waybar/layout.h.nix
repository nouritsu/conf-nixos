{...}: {
  programs.waybar.settings.default = {
    modules-left = [
      "custom/left_div#1"
      "hyprland/workspaces"
      "custom/right_div#1"
      "hyprland/window"
    ];

    modules-center = [
      "hyprland/windowcount"
      "custom/left_div#2"
      "custom/temperature"
      "custom/left_div#3"
      "custom/memory"
      "custom/left_div#4"
      "cpu"
      "custom/left_inv#1"
      "custom/left_div#5"
      "custom/distro"
      "custom/right_div#2"
      "custom/right_inv#1"
      "idle_inhibitor"
      "custom/time"
      "custom/right_div#3"
      "custom/date"
      "custom/right_div#4"
      "network"
      "bluetooth"
      "custom/right_div#5"
    ];

    modules-right = [
      "mpris"
      "custom/left_div#6"
      "group/pulseaudio"
      "custom/left_div#7"
      "backlight"
      "custom/left_div#8"
      "battery"
      "custom/left_inv#2"
      "tray"
      "custom/right_div#1"
    ];
  };
}
