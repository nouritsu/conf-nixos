{
  perSystem = {pkgs, ...}: let
    # the first razer mouse as one json line, or {}; `dpi <serial> <value>` sets both axes
    razer = pkgs.writeShellApplication {
      name = "dux-razer-mouse";
      runtimeInputs = [pkgs.jq pkgs.systemd];
      text = ''
        call() {
          busctl --user --json=short call org.razer "$@" | jq -c '.data[0]'
        }

        if [ "''${1:-}" = dpi ]; then
          busctl --user call org.razer "/org/razer/device/$2" razer.device.dpi setDPI qq "$3" "$3"
          exit
        fi

        for serial in $(call /org/razer razer.devices getDevices | jq -r '.[]'); do
          path=/org/razer/device/$serial
          [ "$(call "$path" razer.device.misc getDeviceType)" = '"mouse"' ] || continue
          name=$(call "$path" razer.device.misc getDeviceName)
          # the dongle answers for a sleeping mouse, but its reads time out
          if ! battery=$(call "$path" razer.device.power getBattery 2> /dev/null); then
            jq -nc --arg serial "$serial" --argjson name "$name" '{serial: $serial, name: $name, asleep: true}'
            exit
          fi
          jq -nc \
            --arg serial "$serial" \
            --argjson name "$name" \
            --argjson battery "$battery" \
            --argjson charging "$(call "$path" razer.device.power isCharging)" \
            --argjson dpi "$(call "$path" razer.device.dpi getDPI)" \
            --argjson maxDpi "$(call "$path" razer.device.dpi maxDPI)" \
            '{serial: $serial, name: $name, battery: $battery, charging: $charging, dpi: $dpi[0], maxDpi: $maxDpi, asleep: false}'
          exit
        done
        echo '{}'
      '';
    };
  in {
    # dux widget: the razer mouse's battery, and a dpi menu
    packages.dux-razer-mouse = pkgs.runCommand "dux-razer-mouse" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      substitute ${./RazerMouseWidget.qml} $out/RazerMouseWidget.qml \
        --replace-fail @razer@ ${pkgs.lib.getExe razer}
    '';
  };
}
