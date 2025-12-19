{pkgs, ...}: let
  free = "${pkgs.procps}/bin/free";
  grep = "${pkgs.gnugrep}/bin/grep";
  awk = "${pkgs.gawk}/bin/awk";
  bc = "${pkgs.bc}/bin/bc";

  memory-script = pkgs.writeShellScript "waybar-memory" ''
    mem_info=$(${free} | ${grep} Mem)
    total=$(echo $mem_info | ${awk} '{print $2}')
    used=$(echo $mem_info | ${awk} '{print $3}')
    percentage=$((used * 100 / total))
    used_gb=$(echo "scale=2; $used / 1024 / 1024" | ${bc})
    total_gb=$(echo "scale=2; $total / 1024 / 1024" | ${bc})

    if [ $percentage -ge 90 ]; then
      echo "{\"text\":\"  $percentage%\",\"tooltip\":\"Memory Used: $used_gb/$total_gb GB\",\"class\":\"critical\",\"percentage\":$percentage}"
    elif [ $percentage -ge 75 ]; then
      echo "{\"text\":\"  $percentage%\",\"tooltip\":\"Memory Used: $used_gb/$total_gb GB\",\"class\":\"warning\",\"percentage\":$percentage}"
    else
      echo "{\"text\":\"  $percentage%\",\"tooltip\":\"Memory Used: $used_gb/$total_gb GB\",\"percentage\":$percentage}"
    fi
  '';
in {
  programs.waybar.settings.default."custom/memory" = {
    exec = "${memory-script}";
    return-type = "json";
    interval = 10;
    tooltip = true;
    min-length = 6;
    max-length = 10;
  };
}
