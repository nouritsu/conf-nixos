{pkgs, ...}: let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  awk = "${pkgs.gawk}/bin/awk";
  tr = "${pkgs.coreutils}/bin/tr";

  volume-script = pkgs.writeShellScriptBin "waybar-volume" ''
    VALUE=1
    MIN=0
    MAX=100

    print-usage() {
      local script=''${0##*/}
      cat <<- EOF
    		USAGE: $script [OPTIONS]

    		Adjust default device volume and send a notification with the current level

    		OPTIONS:
    		    input            Set device as '@DEFAULT_SOURCE@'
    		    output           Set device as '@DEFAULT_SINK@'

    		    mute             Toggle device mute

    		    raise <value>    Raise volume by <value>
    		    lower <value>    Lower volume by <value>
    		                         Default value: $VALUE

    		EXAMPLES:
    		    Toggle microphone mute:
    		        $ $script input mute

    		    Raise speaker volume:
    		        $ $script output raise

    		    Lower speaker volume by 5:
    		        $ $script output lower 5
    	EOF
      exit 1
    }

    check-muted() {
      local muted
      muted=$(${pactl} "get-$dev_mute" "$dev" | ${awk} '{print $2}')
      local state
      case $muted in
        'yes') state='Muted' ;;
        'no') state='Unmuted' ;;
      esac

      echo "$state"
    }

    get-volume() {
      ${pactl} "get-$dev_vol" "$dev" | ${awk} '{print $5}' | ${tr} -d '%'
    }

    get-icon() {
      local icon
      local new_vol=''${1:-$(get-volume)}

      if [[ $(check-muted) == 'Muted' ]]; then
        icon="$dev_icon-muted"
      else
        if ((new_vol < ((MAX * 33) / 100))); then
          icon="$dev_icon-low"
        elif ((new_vol < ((MAX * 66) / 100))); then
          icon="$dev_icon-medium"
        else
          icon="$dev_icon-high"
        fi
      fi

      echo "$icon"
    }

    toggle-mute() {
      ${pactl} "set-$dev_mute" "$dev" toggle
      ${notify-send} "$title: $(check-muted)" -i "$(get-icon)" -r 2425 -h string:x-canonical-private-synchronous:volume
     }

    set-volume() {
      local vol
      vol=$(get-volume)
      local new_vol

      case $action in
        'raise')
          new_vol=$((vol + value))
          ((new_vol > MAX)) && new_vol=$MAX
          ;;
        'lower')
          new_vol=$((vol - value))
          ((new_vol < MIN)) && new_vol=$MIN
          ;;
      esac

      ${pactl} "set-$dev_vol" "$dev" "''${new_vol}%"

      local icon
      icon=$(get-icon "$new_vol")

      ${notify-send} "$title: ''${new_vol}%" -h int:value:$new_vol -i "$icon" -r 2425 -h string:x-canonical-private-synchronous:volume
    }

    main() {
      device=$1
      action=$2
      value=''${3:-$VALUE}

      ! ((value > 0)) && print-usage

      case $device in
        'input')
          dev='@DEFAULT_SOURCE@'
          dev_mute='source-mute'
          dev_vol='source-volume'
          dev_icon='mic-volume'
          title='Microphone'
          ;;
        'output')
          dev='@DEFAULT_SINK@'
          dev_mute='sink-mute'
          dev_vol='sink-volume'
          dev_icon='audio-volume'
          title='Volume'
          ;;
        *) print-usage ;;
      esac

      case $action in
        'mute') toggle-mute ;;
        'raise' | 'lower') set-volume ;;
        *) print-usage ;;
      esac
    }

    main "$@"
  '';
in {
  programs.waybar.settings.default = {
    "group/pulseaudio" = {
      orientation = "horizontal";
      modules = [
        "pulseaudio#output"
        "pulseaudio#input"
      ];
      drawer = {
        transition-left-to-right = false;
      };
    };

    "pulseaudio#output" = {
      format = "{icon} {volume}%";
      format-muted = "{icon}";
      format-icons = {
        default = [
          " "
          " "
          " "
        ];
        default-muted = " ";
        headphone = "󰋋 ";
        headphone-muted = "󰟎 ";
        headset = "󰥰 ";
        headset-muted = "󰟎 ";
      };
      min-length = 7;
      max-length = 7;
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-click-right = "${volume-script}/bin/waybar-volume output mute";
      on-scroll-up = "${volume-script}/bin/waybar-volume output raise";
      on-scroll-down = "${volume-script}/bin/waybar-volume output lower";
      tooltip-format = "<b>Output Device</b>: {desc}";
    };

    "pulseaudio#input" = {
      format-source = " {volume}%";
      format-source-muted = " ";
      min-length = 7;
      max-length = 7;
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-click-right = "${volume-script}/bin/waybar-volume input mute";
      on-scroll-up = "${volume-script}/bin/waybar-volume input raise";
      on-scroll-down = "${volume-script}/bin/waybar-volume input lower";
      tooltip-format = "<b>Input Device</b>: {desc}";
    };
  };
}
