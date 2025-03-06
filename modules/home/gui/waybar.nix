{...}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        height = 16;
        spacing = 0;
        fixed-center = true;

        modules-left = [
          "custom/logo"
          "hyprland/workspaces"
        ];

        modules-right = [
          "pulseaudio"
          "battery"
          "clock"
          "tray"
        ];

        battery = {
          bat = "BAT1";
          adapter = "ADP0";
          interval = 1;
          states = {
            warning = 30;
            critical = 15;
          };
          max-length = 20;
          format = "{icon}{capacity}%";
          format-warning = "{icon}{capacity}%";
          format-critical = "{icon}{capacity}%";
          format-charging = "<span foreground='#26ff55'> {capacity} %</span>";
          format-plugged = "<span foreground='#26ff55'>  {capacity}%</span>";
          format-alt = "{icon} {time}";
          format-full = "<span foreground='#26ff55'> {capacity} %</span>";
          format-icons = ["󰂎" "󰁻" "󰁾" "󰂀" "󰁹"];
        };

        clock = {
          format = "<span color='#6bfffd'> </span>{:%I:%M %p}";
          format-alt = "<span color='#ff9854'> </span>{:%a %b %d}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "  {usage}%";
          tooltip = true;
          interval = 1;
        };

        memory = {
          format = "  {used:0.2f}G";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "  muted";
          format-icons = {
            headphone = "󰋋 ";
            hands-free = "󰂰 ";
            headset = "󰋋 ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [" " " " " "];
          };
        };

        "custom/logo" = {
          format = " ";
          toolip = false;
        };

        "custom/sep" = {
          format = "|";
          tooltip = false;
        };

        # "custom/power" = {
        #   format = " ";
        # };
      }
    ];
  };
}
