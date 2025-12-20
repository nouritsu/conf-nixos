{
  config,
  pkgs,
  ...
}: let
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
in {
  programs.waybar.settings.default.bluetooth = {
    format = "{icon}";
    format-disabled = "󰂲";
    format-off = "󰂲";
    format-on = "󰂳";
    format-connected = "󰂱";
    min-length = 2;
    max-length = 2;
    on-click = "${pkgs.blueman}/bin/blueman-manager";
    on-click-right = "${bluetoothctl} power off && ${notify-send} 'Bluetooth Off' -i 'network-bluetooth-inactive' -r 1925 -h string:x-canonical-private-synchronous:bluetooth";
    tooltip-format = "Device Addr: {device_address}";
    tooltip-format-disabled = "Bluetooth Disabled";
    tooltip-format-off = "Bluetooth Off";
    tooltip-format-on = "Bluetooth Disconnected";
    tooltip-format-connected = "Device: {device_alias}";
    tooltip-format-enumerate-connected = "Device: {device_alias}";
    tooltip-format-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
    tooltip-format-enumerate-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
  };
}
