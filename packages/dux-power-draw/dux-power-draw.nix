{
  perSystem = {pkgs, ...}: let
    # one json line a second: rapl counters, cpu rail and temperature, clocks,
    # cpu time, battery voltage and conservation mode
    sampler = pkgs.writeShellApplication {
      name = "dux-power-draw-sampler";
      runtimeInputs = [pkgs.coreutils pkgs.pciutils];
      text = builtins.readFile ./sampler.sh;
    };

    # upower's charge history for the laptop battery
    history = pkgs.writeShellApplication {
      name = "dux-power-draw-history";
      runtimeInputs = [pkgs.upower pkgs.glib];
      text = ''
        device=""
        while read -r path; do
          case $path in
            */battery_*)
              device=$path
              break
              ;;
          esac
        done < <(upower -e)
        [ -n "$device" ] || exit 1
        gdbus call --system --dest org.freedesktop.UPower --object-path "$device" \
          --method org.freedesktop.UPower.Device.GetHistory charge 86400 288
      '';
    };

    # writes 0 or 1 and nothing else; polkit names it for the ideapad
    conservation = pkgs.writeShellScript "dux-power-draw-conservation" ''
      [[ $1 == [01] ]] || exit 2
      echo "$1" > /sys/bus/platform/devices/VPC2004:00/conservation_mode
    '';
  in {
    # dux widget: power draw, battery, conservation mode and power profiles
    packages.dux-power-draw = pkgs.runCommand "dux-power-draw" {passthru = {inherit conservation;};} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      cp ${./PowerDrawWidget.qml} $out/PowerDrawWidget.qml
      substitute ${./PowerDrawDaemon.qml} $out/PowerDrawDaemon.qml \
        --replace-fail @sampler@ ${pkgs.lib.getExe sampler} \
        --replace-fail @history@ ${pkgs.lib.getExe history} \
        --replace-fail @conservation@ ${conservation}
    '';
  };
}
