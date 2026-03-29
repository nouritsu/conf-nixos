{
  flake.nixosModules.app-screenshot = {...}: {
    my.hmModules = ["app-screenshot"];
  };

  flake.homeModules.app-screenshot = {
    pkgs,
    inputs,
    osConfig,
    ...
  }: let
    screenshot-dir-home = "images/screenshots";

    hyprland-pkg = inputs.hyprland.packages.${osConfig.my.system.arch}.hyprland;
    screenshot = pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = [
        pkgs.grim
        pkgs.slurp
        pkgs.swappy
        hyprland-pkg
        pkgs.jq
        pkgs.gum
        pkgs.nettools
        pkgs.libnotify
        pkgs.xdg-utils
        pkgs.wl-clipboard
      ];
      text = ''
        MODE="$1"
        LOG_FILE="$HOME/.local/state/screenshot/screenshot.log"
        mkdir -p "$(dirname "$LOG_FILE")"
        log() { gum log --level "$1" "$2" 2>&1 | tee -a "$LOG_FILE"; }
        TIME=$(date +%Y-%m-%dT%H:%M:%S)
        HNAME=$(hostname)
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
        log debug "starting screenshot - mode: $MODE, monitor: $MONITOR"

        case "$MODE" in
          "monitor")
            FILEPATH="$HOME/${screenshot-dir-home}/monitor/$HNAME-$TIME-$MONITOR.png"
            ;;
          "region")
            REGION=$(slurp) || { log error "region selection cancelled"; exit 1; }
            FILEPATH="$HOME/${screenshot-dir-home}/region/$HNAME-$TIME-$MONITOR($(echo "$REGION" | tr ' ' '_')).png"
            ;;
          "window")
            WIN=$(hyprctl activewindow -j)
            GEOM=$(echo "$WIN" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            FILEPATH="$HOME/${screenshot-dir-home}/window/$HNAME-$TIME-$MONITOR-$(echo "$WIN" | jq -r '.class').png"
            ;;
          *)
            log error "invalid mode: '$MODE'. valid modes: 'monitor', 'region', 'window'"
            exit 1
            ;;
        esac

        capture() {
          case "$MODE" in
            "monitor") grim -o "$MONITOR" - ;;
            "region")  grim -g "$REGION" - ;;
            "window")  grim -g "$GEOM" - ;;
          esac
        }

        notify_success() {
          notify-send -a "Screenshot" \
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
            "open") xdg-open "$FILEPATH" ;;
            "edit") swappy -f "$FILEPATH" -o "''${FILEPATH%.png}-edited.png" ;;
            "folder") xdg-open "$(dirname "$FILEPATH")" ;;
            "delete")
              rm "$FILEPATH"
              log info "screenshot deleted: $FILEPATH"
              ;;
          esac
        }

        # main
        mkdir -p "$(dirname "$FILEPATH")"
        log info "taking $MODE screenshot"

        if capture | tee "$FILEPATH" | wl-copy -t image/png; then
          log info "screenshot saved to: $FILEPATH"
          ACTION=$(notify_success)
          handle_action "$ACTION"
        else
          log error "screenshot failed"
          notify-send -a "Screenshot" -u critical "Screenshot failed" "Could not capture $MODE"
        fi
      '';
    };
  in {
    home.packages = [
      screenshot
    ];

    # TODO: move to NIRI
  };
}
