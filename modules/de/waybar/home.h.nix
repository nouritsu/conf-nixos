{config, ...}: let
  colors = config.lib.stylix.colors;
in {
  imports = [
    ./modules/home.h.nix
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
      /* Catppuccin Mocha via Stylix */

      @define-color rosewater #${colors.base06};
      @define-color flamingo #${colors.base0F};
      @define-color pink #f5c2e7;
      @define-color mauve #${colors.base0E};
      @define-color red #${colors.base08};
      @define-color maroon #eba0ac;
      @define-color peach #${colors.base09};
      @define-color yellow #${colors.base0A};
      @define-color green #${colors.base0B};
      @define-color teal #${colors.base0C};
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #${colors.base0D};
      @define-color lavender #${colors.base07};
      @define-color text #${colors.base05};
      @define-color subtext1 #${colors.base04};
      @define-color subtext0 #${colors.base04};
      @define-color overlay2 #${colors.base03};
      @define-color overlay1 #${colors.base03};
      @define-color overlay0 #${colors.base03};
      @define-color surface2 #${colors.base03};
      @define-color surface1 #${colors.base03};
      @define-color surface0 #${colors.base02};
      @define-color base #${colors.base00};
      @define-color mantle #${colors.base01};
      @define-color crust #${colors.base01};
    '' + builtins.readFile ./styles.css;
    settings.default = {
      layer = "top";
      position = "top";
      mode = "dock";
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      height = 0;
      spacing = 0;
      fixed-center = true;
      reload_style_on_change = true;

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
        "custom/power_menu"
      ];

      tray = {
        show-passive-items = true;
        spacing = 10;
      };
    };
  };
}
