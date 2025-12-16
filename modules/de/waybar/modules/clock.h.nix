{pkgs, ...}: let
  date = "${pkgs.coreutils}/bin/date";

  time-script = pkgs.writeShellScript "waybar-time" ''
    hour=$(${date} +%H)
    time=$(${date} +%H:%M)
    tooltip=$(${date} '+%I:%M %p')

    case $hour in
      00) icon="󱑖 " ;;
      01) icon="󱑋 " ;;
      02) icon="󱑌 " ;;
      03) icon="󱑍 " ;;
      04) icon="󱑎 " ;;
      05) icon="󱑏 " ;;
      06) icon="󱑐 " ;;
      07) icon="󱑑 " ;;
      08) icon="󱑒 " ;;
      09) icon="󱑓 " ;;
      10) icon="󱑔 " ;;
      11) icon="󱑕 " ;;
      12) icon="󱑖 " ;;
      13) icon="󱑋 " ;;
      14) icon="󱑌 " ;;
      15) icon="󱑍 " ;;
      16) icon="󱑎 " ;;
      17) icon="󱑏 " ;;
      18) icon="󱑐 " ;;
      19) icon="󱑑 " ;;
      20) icon="󱑒 " ;;
      21) icon="󱑓 " ;;
      22) icon="󱑔 " ;;
      23) icon="󱑕 " ;;
      *) icon="󱡦 " ;;
    esac

    echo "{\"text\":\"$icon $time\",\"tooltip\":\"Standard Time: $tooltip\"}"
  '';

  date-script = pkgs.writeShellScript "waybar-date" ''
    echo "󰃭  $(${date} +%d-%m)"
  '';
in {
  programs.waybar.settings.default = {
    "custom/time" = {
      exec = "${time-script}";
      return-type = "json";
      interval = 5;
      min-length = 8;
      max-length = 8;
      tooltip = true;
    };

    "custom/date" = {
      exec = "${date-script}";
      interval = 60;
      min-length = 8;
      max-length = 8;
    };
  };
}
