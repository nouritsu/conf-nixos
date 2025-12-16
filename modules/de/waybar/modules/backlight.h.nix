{pkgs, ...}: let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  notify-send = "${pkgs.libnotify}/bin/notify-send";

  backlight-script = pkgs.writeShellScriptBin "waybar-backlight" ''
    case "$1" in
      up)
        ${brightnessctl} set +5%
        brightness=$(${brightnessctl} get)
        max=$(${brightnessctl} max)
        percent=$((brightness * 100 / max))
        ${notify-send} "Brightness" "$percent%" -i display-brightness -r 1426 -h int:value:$percent -h string:x-canonical-private-synchronous:brightness
        ;;
      down)
        ${brightnessctl} set 5%-
        brightness=$(${brightnessctl} get)
        max=$(${brightnessctl} max)
        percent=$((brightness * 100 / max))
        ${notify-send} "Brightness" "$percent%" -i display-brightness -r 1426 -h int:value:$percent -h string:x-canonical-private-synchronous:brightness
        ;;
    esac
  '';
in {
  programs.waybar.settings.default.backlight = {
    format = "{icon} {percent}%";
    format-icons = [
      "󰃞 "
      "󰃞 "
      "󰃟 "
      "󰃟 "
      "󰃟 "
      "󰃝 "
      "󰃝 "
      "󰃝 "
      "󰃠 "
    ];
    min-length = 7;
    max-length = 7;
    on-scroll-up = "${backlight-script}/bin/waybar-backlight up";
    on-scroll-down = "${backlight-script}/bin/waybar-backlight down";
    tooltip = false;
  };
}
