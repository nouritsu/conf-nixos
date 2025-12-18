{config, pkgs, ...}: let
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  rfkill = "${pkgs.util-linux}/bin/rfkill";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  fzf = "${pkgs.fzf}/bin/fzf";
  awk = "${pkgs.gawk}/bin/awk";
  grep = "${pkgs.gnugrep}/bin/grep";
  sed = "${pkgs.gnused}/bin/sed";
  timeout = "${pkgs.coreutils}/bin/timeout";
  tput = "${pkgs.ncurses}/bin/tput";
  printf = "${pkgs.coreutils}/bin/printf";

  bluetooth-script = pkgs.writeShellScriptBin "waybar-bluetooth" ''
    RED='\033[1;31m'
    RST='\033[0m'
    TIMEOUT=10

    cleanup() {
      ${tput} cnorm
    }
    trap cleanup EXIT

    wait-for-key() {
      ${printf} '\n%bPress [q] or [ESC] to close%b\n' "$RED" "$RST"
      while true; do
        read -rsn1 key
        if [[ $key == 'q' || $key == 'Q' || $key == $'\e' ]]; then
          break
        fi
      done
    }

    ensure-on() {
      local status
      status=$(${bluetoothctl} show | ${awk} '/PowerState/ {print $2}')

      case $status in
        'off')
          ${bluetoothctl} power on > /dev/null
          ;;
        'off-blocked')
          ${rfkill} unblock bluetooth

          local i new_status
          for ((i = 1; i <= TIMEOUT; i++)); do
            ${printf} '\rUnblocking Bluetooth... (%d/%d)' $i $TIMEOUT

            new_status=$(${bluetoothctl} show | ${awk} '/PowerState/ {print $2}')
            if [[ $new_status == 'on' ]]; then
              break
            fi
            sleep 1
          done

          if [[ $new_status != 'on' ]]; then
            ${notify-send} 'Bluetooth' 'Failed to unblock' -i 'package-purge' -r 1925
            return 1
          fi
          ;;
        *) return 0 ;;
      esac

      ${notify-send} 'Bluetooth On' -i 'network-bluetooth-activated' -r 1925 -h string:x-canonical-private-synchronous:bluetooth
    }

    get-device-list() {
      ${bluetoothctl} --timeout $TIMEOUT scan on > /dev/null 2>&1 &
      local scan_pid=$!

      local i num
      for ((i = 1; i <= TIMEOUT; i++)); do
        ${printf} '\rScanning for devices... (%d/%d) - Press [q] to stop' $i $TIMEOUT
        ${printf} '\n\n'

        num=$(${bluetoothctl} devices 2>/dev/null | ${grep} -c 'Device' 2>/dev/null || echo "0")
        ${printf} 'Devices found: %s' "$num"
        ${printf} '\033[2A\r'

        read -rs -n 1 -t 1 || true
        if [[ $REPLY == [Qq] ]]; then
          break
        fi
      done
      ${printf} '\n\n%bScanning stopped.%b\n\n' "$RED" "$RST"

      # Stop scanning
      kill $scan_pid 2>/dev/null || true
      ${bluetoothctl} scan off > /dev/null 2>&1 || true

      list=$(${bluetoothctl} devices 2>/dev/null | ${sed} 's/^Device //' 2>/dev/null || true)
      if [[ -z $list ]]; then
        ${notify-send} 'Bluetooth' 'No devices found' -i 'package-broken' -r 1925
        return 1
      fi
    }

    select-device() {
      local header
      header=$(${printf} '%-17s %s' 'Address' 'Name')
      local opts=(
        '--border=sharp'
        '--border-label= Bluetooth Devices '
        '--ghost=Search'
        "--header=$header"
        '--height=~100%'
        '--width=95%'
        '--highlight-line'
        '--info=inline-right'
        '--pointer='
        '--reverse'
      )

      address=$(${fzf} "''${opts[@]}" <<< "$list" | ${awk} '{print $1}')
      if [[ -z $address ]]; then
        return 1
      fi

      local connected
      connected=$(${bluetoothctl} info "$address" | ${awk} '/Connected/ {print $2}')
      if [[ $connected == 'yes' ]]; then
        ${notify-send} 'Bluetooth' 'Already connected to this device' -i 'package-install' -r 1925
        return 1
      fi
    }

    pair-and-connect() {
      local paired
      paired=$(${bluetoothctl} info "$address" | ${awk} '/Paired/ {print $2}')
      if [[ $paired == 'no' ]]; then
        ${printf} 'Pairing...'
        if ! ${timeout} $TIMEOUT ${bluetoothctl} pair "$address" > /dev/null; then
          ${notify-send} 'Bluetooth' 'Failed to pair' -i 'package-purge' -r 1925
          return 1
        fi
      fi

      ${printf} '\nConnecting...'
      if ! ${timeout} $TIMEOUT ${bluetoothctl} connect "$address" > /dev/null; then
        ${notify-send} 'Bluetooth' 'Failed to connect' -i 'package-purge' -r 1925
        return 1
      fi
      ${notify-send} 'Bluetooth' 'Successfully connected' -i 'package-install' -r 1925 -h string:x-canonical-private-synchronous:bluetooth
    }

    main() {
      ${tput} civis
      ensure-on || { wait-for-key; exit 1; }
      get-device-list || { wait-for-key; exit 1; }
      select-device || exit 0
      pair-and-connect || { wait-for-key; exit 1; }
    }

    main
  '';
in {
  programs.waybar.settings.default.bluetooth = {
    format = "{icon}";
    format-disabled = "󰂲";
    format-off = "󰂲";
    format-on = "󰂳";
    format-connected = "󰂱";
    min-length = 2;
    max-length = 2;
    on-click = "${config.programs.wezterm.package}/bin/wezterm start --class waybar-bluetooth -- ${bluetooth-script}/bin/waybar-bluetooth";
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
