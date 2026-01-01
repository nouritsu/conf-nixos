{
  waybar_lib,
  pkgs,
  ...
}: let
  terminal-launch = "${pkgs.wezterm}/bin/wezterm-gui start";
  btop = "${pkgs.btop}/bin/btop";
in {
  programs.waybar.settings.default = {
    cpu = {
      interval = 15;
      format = "   {usage}%";
      format-warning = "   {usage}%";
      format-critical = "   {usage}%";
      on-click = "${terminal-launch} ${btop}";
      states = {
        warning = 75;
        critical = 90;
      };
    };

    temperature = {
      interval = 15;
      format = "  {temperatureC}°C";
      hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
    };
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "cpu-fg: @surface0"
      "cpu-bg: @lavender"
      "cpu-fg-warning: @peach"
      "cpu-fg-critical: @red"

      "cpu-temp-fg: @cpu-fg"
      "cpu-temp-bg: @cpu-bg"
      "cpu-temp-fg-warning: @cpu-fg-warning"
      "cpu-temp-fg-critical: @cpu-fg-critical"
    ];

    parts =
      /*
      css
      */
      ''
        #cpu {
          color: @cpu-fg;
          background-color: @cpu-bg;
          padding-left: 6px;
        }

        #cpu.warning {
          color: @cpu-fg-warning;
        }

        #cpu.critical {
          color: @cpu-fg-critical;
        }

        #temperature {
          color: @cpu-temp-fg;
          background-color: @cpu-temp-bg;
          padding-right: 10px;
        }

        #temperature.warning {
          color: @cpu-temp-fg-warning;
        }

        #temperature.critical {
          color: @cpu-temp-fg-critical;
        }
      '';
  };
}
