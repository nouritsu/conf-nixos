{pkgs, ...}: let
  notify-send = "${pkgs.libnotify}/bin/notify-send";
in {
  programs.waybar.settings.default.battery = {
    states = {
      warning = 20;
      critical = 10;
    };
    format = "{icon} {capacity}%";
    format-time = "{H}h {M}min";
    format-icons = [
      "󰂎"
      "󰁺"
      "󰁻"
      "󰁼"
      "󰁽"
      "󰁾"
      "󰁿"
      "󰂀"
      "󰂁"
      "󰂂"
      "󰁹"
    ];
    format-charging = "󰂄 {capacity}%";
    min-length = 7;
    max-length = 7;
    tooltip-format = "<b>Discharging</b>: {time}";
    tooltip-format-charging = "<b>Charging</b>: {time}";
    events = {
      on-discharging-warning = "${notify-send} 'Battery Low (20%)' 'Please connect charger' -u critical -i battery-020 -r 1525 -h string:x-canonical-private-synchronous:battery";
      on-discharging-critical = "${notify-send} 'Battery Critical (10%)' 'Connect charger immediately!' -u critical -i battery-010 -r 1525 -h string:x-canonical-private-synchronous:battery -h int:value:10";
      on-charging-100 = "${notify-send} 'Battery Full (100%)' 'You can disconnect the charger' -i battery-100-charged -r 1525 -h string:x-canonical-private-synchronous:battery";
    };
  };
}
