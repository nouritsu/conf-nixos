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
        height = 0;

        modules-left = [
          "clock"
          "hyprland/workspaces"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "tray"
          "memory"
          "cpu"
          "network"
          "battery"
          "backlight"
          "pulseaudio"
          "pulseaudio#microphone"
        ];

        "hyprland/window" = {
          format = "  {}";
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
        };

        tray = {
          icon-size = 13;
          spacing = 10;
        };

        clock = {
          format = "{:%A    %B-%d-%Y    %I:%M:%S %p}";
          interval = 1;
          rotate = 0;
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
          };
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = ["󰃞 " "󰃟 " "󰃠 "];
        };
      }
    ];
  };
}
