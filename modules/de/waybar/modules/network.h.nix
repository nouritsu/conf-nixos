{pkgs, ...}: let
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  networkmanagerapplet = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
in {
  programs.waybar.settings.default.network = {
    interval = 10;
    format = "{icon}";
    format-ethernet = "󰈀 ";
    format-wifi = " ";
    format-disconnected = "󱛅 ";
    format-disabled = "󰖪 ";
    format-icons = [
      "󰤫 "
      "󰤟 "
      "󰤢 "
      "󰤨 "
    ];
    min-length = 2;
    max-length = 2;
    on-click = networkmanagerapplet;
    on-click-right = "${nmcli} radio wifi off && ${notify-send} 'Wi-Fi Disabled' -i 'network-wireless-off' -r 1125 -h string:x-canonical-private-synchronous:network";
    tooltip-format = "<b>Gateway</b>: {gwaddr}";
    tooltip-format-ethernet = "<b>Interface</b>: {ifname}";
    tooltip-format-wifi = "<b>Network</b>: {essid}\n<b>IP Addr</b>: {ipaddr}/{cidr}\n<b>Strength</b>: {signalStrength}%\n<b>Frequency</b>: {frequency} GHz";
    tooltip-format-disconnected = "Wi-Fi Disconnected";
    tooltip-format-disabled = "Wi-Fi Disabled";
  };
}
