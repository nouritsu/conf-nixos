{config, pkgs, ...}: let
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  fzf = "${pkgs.fzf}/bin/fzf";
  awk = "${pkgs.gawk}/bin/awk";
  head = "${pkgs.coreutils}/bin/head";
  tail = "${pkgs.coreutils}/bin/tail";
  tput = "${pkgs.ncurses}/bin/tput";

  network-script = pkgs.writeShellScriptBin "waybar-network" ''
    RED='\033[1;31m'
    RST='\033[0m'
    TIMEOUT=5

    ensure-enabled() {
      local radio
      radio=$(${nmcli} radio wifi)
      if [[ $radio == 'enabled' ]]; then
        return 0
      fi
      ${nmcli} radio wifi on

      local i state
      for ((i = 1; i <= TIMEOUT; i++)); do
        printf '\rEnabling Wi-Fi... (%d/%d)' $i $TIMEOUT

        state=$(${nmcli} -t -f STATE general)
        if [[ $state != 'connected (local only)' ]]; then
          break
        fi
        sleep 1
      done
      ${notify-send} 'Wi-Fi Enabled' -i 'network-wireless-on' -r 1125 -h string:x-canonical-private-synchronous:network
    }

    get-network-list() {
      ${nmcli} device wifi rescan

      local i
      for ((i = 1; i <= TIMEOUT; i++)); do
        printf '\rScanning for networks... (%d/%d)' $i $TIMEOUT

        list=$(timeout 1 ${nmcli} device wifi list)
        networks=$(${tail} -n +2 <<< "$list" | ${awk} '$2 != "--"')
        if [[ -n $networks ]]; then
          break
        fi
      done
      printf '\n%bScanning stopped.%b\n\n' "$RED" "$RST"

      if [[ -z $networks ]]; then
        ${notify-send} 'Wi-Fi' 'No networks found' -i 'package-broken' -r 1125
        return 1
      fi
    }

    select-network() {
      local header
      header=$(${head} -n 1 <<< "$list")
      local opts=(
        '--border=sharp'
        '--border-label= Wi-Fi Networks '
        '--ghost=Search'
        "--header=$header"
        '--height=~100%'
        '--highlight-line'
        '--info=inline-right'
        '--pointer='
        '--reverse'
      )

      bssid=$(${fzf} "''${opts[@]}" <<< "$networks" | ${awk} '{print $1}')
      if [[ -z $bssid ]]; then
        return 1
      fi
      if [[ $bssid == '*' ]]; then
        ${notify-send} 'Wi-Fi' 'Already connected to this network' -i 'package-install' -r 1125
        return 1
      fi
    }

    connect-to-network() {
      printf 'Connecting...\n'
      if ! ${nmcli} --ask device wifi connect "$bssid"; then
        ${notify-send} 'Wi-Fi' 'Failed to connect' -i 'package-purge' -r 1125
        return 1
      fi
      ${notify-send} 'Wi-Fi' 'Successfully connected' -i 'package-install' -r 1125 -h string:x-canonical-private-synchronous:network
    }

    main() {
      ${tput} civis
      ensure-enabled || exit 1
      get-network-list || exit 1
      ${tput} cnorm
      select-network || exit 1
      connect-to-network || exit 1
    }

    main
  '';
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
    on-click = "${config.programs.wezterm.package}/bin/wezterm start --class waybar-network -- ${network-script}/bin/waybar-network";
    on-click-right = "${nmcli} radio wifi off && ${notify-send} 'Wi-Fi Disabled' -i 'network-wireless-off' -r 1125 -h string:x-canonical-private-synchronous:network";
    tooltip-format = "<b>Gateway</b>: {gwaddr}";
    tooltip-format-ethernet = "<b>Interface</b>: {ifname}";
    tooltip-format-wifi = "<b>Network</b>: {essid}\n<b>IP Addr</b>: {ipaddr}/{cidr}\n<b>Strength</b>: {signalStrength}%\n<b>Frequency</b>: {frequency} GHz";
    tooltip-format-disconnected = "Wi-Fi Disconnected";
    tooltip-format-disabled = "Wi-Fi Disabled";
  };
}
