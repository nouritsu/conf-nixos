{
  pkgs,
  waybar_lib,
  ...
}: let
  sig = 9;

  # Cache file for the clock icon
  icon_cache = "$XDG_RUNTIME_DIR/waybar-clock-icon";

  date = "${pkgs.coreutils}/bin/date";
  echo = "${pkgs.coreutils}/bin/echo";
  cat = "${pkgs.coreutils}/bin/cat";
  pkill = "${pkgs.procps}/bin/pkill";
  gum = "${pkgs.gum}/bin/gum";

  update-icon = pkgs.writeShellScript "waybar-clock-update-icon" ''
    hour=$(${date} +%H)

    case $hour in
      00|12) icon="󱑖" ;;
      01|13) icon="󱑋" ;;
      02|14) icon="󱑌" ;;
      03|15) icon="󱑍" ;;
      04|16) icon="󱑎" ;;
      05|17) icon="󱑏" ;;
      06|18) icon="󱑐" ;;
      07|19) icon="󱑑" ;;
      08|20) icon="󱑒" ;;
      09|21) icon="󱑓" ;;
      10|22) icon="󱑔" ;;
      11|23) icon="󱑕" ;;
      *) icon="󱡦" ;;
    esac

    ${echo} "$icon" > ${icon_cache}
    ${gum} log --level info "clock icon updated to: $icon (hour: $hour)"

    if ${pkill} -SIGRTMIN+${builtins.toString sig} -x .waybar-wrapped; then
      ${gum} log --level info "waybar signalled for clock update"
    else
      ${gum} log --level warn "could not signal waybar, is it running?"
    fi
  '';

  clock-display = pkgs.writeShellScript "waybar-clock-display" ''
    if [ -f ${icon_cache} ]; then
      icon=$(${cat} ${icon_cache})
    else
      ${gum} log --level warn "icon cache does not exist"
      icon="󱡦"
    fi

    # Format: YYYY-MM-DD {icon} HH:MM:SS
    datetime=$(${date} '+%Y-%m-%d')
    time=$(${date} '+%H:%M:%S')

    ${echo} "$datetime $icon  $time"
  '';

  timer-updater = pkgs.writeShellScriptBin "waybar-clock-timer" ''
    ${gum} log --level info "starting waybar clock icon updater"
    ${update-icon}
  '';
in {
  programs.waybar.settings.default."custom/clock" = {
    format = "{}";
    exec = "${clock-display}";
    interval = 1;
    signal = sig;
    tooltip = false;
  };

  systemd.user.timers.waybar-clock-updater = {
    Unit = {
      Description = "Update waybar clock icon hourly";
    };

    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
      AccuracySec = "1s";
    };

    Install = {
      WantedBy = ["timers.target"];
    };
  };

  systemd.user.services.waybar-clock-updater = {
    Unit = {
      Description = "Update waybar clock icon based on current hour";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${timer-updater}/bin/waybar-clock-timer";
    };
  };

  systemd.user.services.waybar-clock-init = {
    Unit = {
      Description = "Initialize waybar clock icon on startup";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${update-icon}";
      RemainAfterExit = false;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "clock-fg: @text"
      "clock-bg: @mantle"
    ];

    parts =
      /*
      css
      */
      ''
        #custom-clock {
          background-color: @clock-bg;
          color: @clock-fg;
          padding: 0 8px;
        }
      '';
  };
}
