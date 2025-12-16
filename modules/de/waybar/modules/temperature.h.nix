{pkgs, ...}: let
  cat = "${pkgs.coreutils}/bin/cat";
  bc = "${pkgs.bc}/bin/bc";

  temperature-script = pkgs.writeShellScript "waybar-temperature" ''
    if [ -f /sys/class/thermal/thermal_zone1/temp ]; then
      temp=$(${cat} /sys/class/thermal/thermal_zone1/temp)
      temp_c=$((temp / 1000))
    elif [ -f /sys/class/thermal/thermal_zone0/temp ]; then
      temp=$(${cat} /sys/class/thermal/thermal_zone0/temp)
      temp_c=$((temp / 1000))
    else
      exit 0
    fi

    temp_f=$(echo "scale=1; ($temp_c * 9 / 5) + 32" | ${bc})

    if [ $temp_c -ge 90 ]; then
      echo "{\"text\":\"$temp_c°C\",\"tooltip\":\"Fahrenheit: $temp_f°F\",\"class\":\"critical\",\"percentage\":$temp_c}"
    elif [ $temp_c -ge 75 ]; then
      echo "{\"text\":\"$temp_c°C\",\"tooltip\":\"Fahrenheit: $temp_f°F\",\"class\":\"warning\",\"percentage\":$temp_c}"
    else
      echo "{\"text\":\"$temp_c°C\",\"tooltip\":\"Fahrenheit: $temp_f°F\",\"percentage\":$temp_c}"
    fi
  '';
in {
  programs.waybar.settings.default."custom/temperature" = {
    exec = "${temperature-script}";
    return-type = "json";
    interval = 10;
    min-length = 8;
    max-length = 8;
    tooltip = true;
  };
}
