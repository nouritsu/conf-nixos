{lib, pkgs, ...}: let
  screenshot-dir-home = "images/screenshots";
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  swappy = lib.getExe pkgs.swappy;
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  jq = lib.getExe pkgs.jq;
  gum = lib.getExe pkgs.gum;
  hostname = lib.getExe' pkgs.nettools "hostname";
  notify-send = lib.getExe' pkgs.libnotify "notify-send";
  xdg-open = lib.getExe' pkgs.xdg-utils "xdg-open";
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    MODE="$1"
    LOG_FILE="$HOME/.local/state/screenshot/screenshot.log"
    mkdir -p "$(dirname "$LOG_FILE")"
    log() { ${gum} log --level "$1" "$2" 2>&1 | tee -a "$LOG_FILE"; }
    TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
    HOSTNAME_VALUE=$(${hostname})
    MONITOR_NAME=$(${hyprctl} monitors -j | ${jq} -r '.[] | select(.focused) | .name')
    log debug "starting screenshot - mode: $MODE, monitor: $MONITOR_NAME"

    # obtain region
    case "$MODE" in
      "monitor")
        FILEPATH="$HOME/${screenshot-dir-home}/monitor/$HOSTNAME_VALUE-$TIMESTAMP-$MONITOR_NAME.png"
        ;;
      "region")
        REGION=$(${slurp}) || { log error "region selection cancelled"; exit 1; }
        FILEPATH="$HOME/${screenshot-dir-home}/region/$HOSTNAME_VALUE-$TIMESTAMP-$MONITOR_NAME($(echo "$REGION" | tr ' ' '_')).png"
        ;;
      "window")
        WIN=$(${hyprctl} activewindow -j)
        GEOM=$(echo "$WIN" | ${jq} -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        FILEPATH="$HOME/${screenshot-dir-home}/window/$HOSTNAME_VALUE-$TIMESTAMP-$MONITOR_NAME-$(echo "$WIN" | ${jq} -r '.class').png"
        ;;
      *)
        log error "invalid mode: '$MODE'. valid modes: 'monitor', 'region', 'window'"
        exit 1
        ;;
    esac

    capture() {
      case "$MODE" in
        "monitor") ${grim} -o "$MONITOR_NAME" - ;;
        "region")  ${grim} -g "$REGION" - ;;
        "window")  ${grim} -g "$GEOM" - ;;
      esac
    }

    notify_success() {
      ${notify-send} -a "Screenshot" \
        -i "$FILEPATH" \
        -A "open=Open" \
        -A "edit=Edit" \
        -A "folder=Open Folder" \
        -A "delete=Delete" \
        "Screenshot saved" \
        "$FILEPATH"
    }

    handle_action() {
      case "$1" in
        "open") ${xdg-open} "$FILEPATH" ;;
        "edit") ${swappy} -f "$FILEPATH" -o "''${FILEPATH%.png}-edited.png" ;;
        "folder") ${xdg-open} "$(dirname "$FILEPATH")" ;;
        "delete")
          rm "$FILEPATH"
          log info "screenshot deleted: $FILEPATH"
          ;;
      esac
    }

    # take screenshot
    mkdir -p "$(dirname "$FILEPATH")"
    log info "taking $MODE screenshot"

    if capture | tee "$FILEPATH" | ${wl-copy} -t image/png; then
      log info "screenshot saved to: $FILEPATH"
      ACTION=$(notify_success)
      handle_action "$ACTION"
    else
      log error "screenshot failed"
      ${notify-send} -a "Screenshot" -u critical "Screenshot failed" "Could not capture $MODE"
    fi
  '';
in {
  home.packages = [
    screenshot
  ];
  wayland.windowManager.hyprland.settings.bind = [
    ",PRINT, exec, screenshot monitor"
    "SUPER, PRINT, exec, screenshot region"
    "SUPER SHIFT, PRINT, exec, screenshot window"
  ];
}
