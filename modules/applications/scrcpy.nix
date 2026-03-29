{
  flake.nixosModules.app-scrcpy = {...}: {
    my.hmModules = ["app-scrcpy"];
  };

  flake.homeModules.app-scrcpy = {
    lib,
    pkgs,
    ...
  }: let
    PHONE_MODEL = "Pixel 9 Pro XL";
    CACHE_FILE = "$XDG_RUNTIME_DIR/phone-adb-address";
    AVAHI_TIMEOUT = 5;
    ADB_TIMEOUT = 3;

    gum = lib.getExe pkgs.gum;
    logger = lib.getExe' pkgs.util-linux "logger";

    log = pkgs.writeShellScript "log" ''
      level="$1"
      shift
      message="$*"

      ${gum} log --level "$level" "$message"
      ${logger} -p "user.$level" -t "$(basename "$0")" "$message"
    '';

    phone-connect = pkgs.writeShellApplication {
      name = "phone-connect";
      runtimeInputs = [
        pkgs.avahi
        pkgs.gnugrep
        pkgs.gawk
        pkgs.android-tools
        pkgs.wirelesstools
      ];
      text = ''
        set -uo pipefail

        log() { ${log} "$@"; }

        PHONE_MODEL="${PHONE_MODEL}"
        PHONE_MODEL_ADB="''${PHONE_MODEL// /_}"  # ' ' -> '_'
        ADB_TIMEOUT="${toString ADB_TIMEOUT}"
        AVAHI_TIMEOUT="${toString AVAHI_TIMEOUT}"

        get_ssid() {
          iwgetid -r 2>/dev/null
        }

        validate_connection() {
          local addr="$1"
          local connect_output

          connect_output=$(timeout "$ADB_TIMEOUT" adb connect "$addr" 2>&1) || return 1

          if echo "$connect_output" | grep -qE "(failed|unable|cannot)"; then
            return 1
          fi

          timeout "$ADB_TIMEOUT" adb -s "$addr" get-state 2>/dev/null | grep -q "device"
        }

        # strategy 1: adb devices
        check_adb_devices() {
          log info "checking existing adb connections"

          local devices
          devices=$(adb devices -l 2>/dev/null) || return 1

          # Find our device by model name (IP:PORT format + model match)
          local addr
          addr=$(echo "$devices" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | \
                 grep "model:$PHONE_MODEL_ADB" | awk '{print $1}' | head -1)

          if [[ -z "$addr" ]]; then
            log debug "no existing wireless connections for $PHONE_MODEL"
            return 1
          fi

          log debug "found listed connection: $addr, validating..."

          if validate_connection "$addr"; then
            log info "found existing connection: $addr"
            echo "$addr"
            return 0
          fi

          log debug "listed connection $addr is stale"
          return 1
        }

        # strategy 2: usb bridge
        check_usb_bridge() {
          log info "checking for USB connection"

          local devices
          devices=$(adb devices -l 2>/dev/null) || return 1

          local usb_line
          usb_line=$(echo "$devices" | grep "model:$PHONE_MODEL_ADB" | \
                     grep -vE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:" | head -1)

          if [[ -z "$usb_line" ]]; then
            log debug "device not connected via USB"
            return 1
          fi

          # Extract the serial from the line
          local serial
          serial=$(echo "$usb_line" | awk '{print $1}')

          log info "device found via USB ($serial), enabling wireless debugging"

          # Get the phone's WiFi IP address
          local phone_ip
          phone_ip=$(adb -s "$serial" shell ip route 2>/dev/null | \
                     grep -oP 'src \K[0-9.]+' | head -1)

          if [[ -z "$phone_ip" ]]; then
            log error "could not determine phone's WiFi IP"
            return 1
          fi

          log info "phone WiFi IP: $phone_ip"

          # Enable tcpip mode on port 5555
          adb -s "$serial" tcpip 5555 >/dev/null 2>&1 || {
            log error "failed to enable tcpip mode"
            return 1
          }

          # Give it a moment to switch modes
          sleep 1

          local addr="$phone_ip:5555"
          if validate_connection "$addr"; then
            log info "USB bridge successful: $addr"
            echo "$addr"
            return 0
          fi

          log error "USB bridge failed to connect to $addr"
          return 1
        }

        # strategy 3: avahi mdns
        check_avahi() {
          log info "scanning mDNS for wireless debugging service"

          local found_addr=""

          # Run avahi-browse with timeout, parse output for our device
          while IFS=';' read -r event _iface proto _name _stype _domain _hostname ip port txt; do
            [[ -z "$event" ]] && continue
            [[ "$event" != "=" ]] && continue
            [[ "$proto" != "IPv4" ]] && continue

            # Check if this is our device (model name in txt field)
            if ! echo "$txt" | grep -q "\"name=$PHONE_MODEL\""; then
              continue
            fi

            log debug "mDNS found device: $ip:$port"
            found_addr="$ip:$port"
            break

          done < <(timeout "$AVAHI_TIMEOUT" avahi-browse -rp _adb-tls-connect._tcp 2>/dev/null || true)

          if [[ -z "$found_addr" ]]; then
            log debug "mDNS scan found no matching devices"
            return 1
          fi

          if validate_connection "$found_addr"; then
            log info "mDNS discovery successful: $found_addr"
            echo "$found_addr"
            return 0
          fi

          log warn "mDNS found $found_addr but connection failed - is wireless debugging enabled?"
          return 1
        }

        # main

        addr=""

        # strategy 1
        if addr=$(check_adb_devices); then
          echo "$addr"
          exit 0
        fi

        # strategy 2
        if addr=$(check_usb_bridge); then
          echo "$addr"
          exit 0
        fi

        # strategy 3
        if addr=$(check_avahi); then
          echo "$addr"
          exit 0
        fi

        ssid=""
        ssid=$(get_ssid)
        if [[ -n "$ssid" ]]; then
          log error "phone not found on network '$ssid'. Is wireless debugging enabled?"
        else
          log error "phone not found. Not connected to WiFi or wireless debugging disabled."
        fi
        exit 1
      '';
    };

    # phone-connect-service: Keepalive service to maintain warm ADB connection
    # Runs every 30 seconds via systemd timer
    phone-connect-service = pkgs.writeShellApplication {
      name = "phone-connect-service";
      runtimeInputs = [
        pkgs.android-tools
        pkgs.gnugrep
        pkgs.libnotify
        phone-connect
      ];
      text = ''
        set -uo pipefail

        log() { ${log} "$@"; }

        CACHE_FILE="${CACHE_FILE}"
        ADB_TIMEOUT="${toString ADB_TIMEOUT}"
        STATE_FILE="$XDG_RUNTIME_DIR/phone-connection-state"

        # State transitions: connected ↔ disconnected
        # Notify only on transitions, not on repeated failures
        get_state() {
          cat "$STATE_FILE" 2>/dev/null || echo "unknown"
        }

        set_state() {
          echo "$1" > "$STATE_FILE"
        }

        # Validate cached connection is still alive
        validate_cached() {
          local addr="$1"

          local connect_output
          connect_output=$(timeout "$ADB_TIMEOUT" adb connect "$addr" 2>&1) || return 1

          if echo "$connect_output" | grep -qE "(failed|unable|cannot)"; then
            return 1
          fi

          timeout "$ADB_TIMEOUT" adb -s "$addr" get-state 2>/dev/null | grep -q "device"
        }

        main() {
          local cached_addr=""
          local prev_state
          prev_state=$(get_state)

          # Try to read cached address
          if [[ -f "$CACHE_FILE" ]]; then
            cached_addr=$(cat "$CACHE_FILE" 2>/dev/null || true)
          fi

          # If we have a cached address, try to validate it
          if [[ -n "$cached_addr" ]]; then
            log debug "validating cached address: $cached_addr"

            if validate_cached "$cached_addr"; then
              log debug "cached connection valid: $cached_addr"

              # Notify on reconnection (disconnected → connected)
              if [[ "$prev_state" == "disconnected" ]]; then
                notify-send -i phone "Phone Connected" "${PHONE_MODEL} reconnected" -u low
              fi

              set_state "connected"
              exit 0
            fi

            log info "cached address $cached_addr is stale"
          fi

          # Cache invalid or missing - run discovery
          log info "running phone discovery"
          local new_addr
          if new_addr=$(phone-connect 2>/dev/null); then
            log info "discovery successful: $new_addr"
            echo "$new_addr" > "$CACHE_FILE"

            # Notify on reconnection (disconnected → connected)
            if [[ "$prev_state" == "disconnected" ]]; then
              notify-send -i phone "Phone Connected" "${PHONE_MODEL} reconnected" -u low
            fi

            set_state "connected"
            exit 0
          fi

          # Discovery failed
          log warn "phone discovery failed"

          # Clear stale cache
          if [[ -f "$CACHE_FILE" ]]; then
            rm -f "$CACHE_FILE"
          fi

          # Notify on disconnection (connected/unknown → disconnected)
          if [[ "$prev_state" != "disconnected" ]]; then
            notify-send -i phone "Phone Disconnected" "${PHONE_MODEL} not found on network" -u normal
          fi

          set_state "disconnected"
          exit 1
        }

        main
      '';
    };

    # phone-mirror: Main user-facing script for mirroring phone display
    # Bound to SUPER+P, uses cached connection for fast startup
    phone-mirror = pkgs.writeShellApplication {
      name = "phone-mirror";
      runtimeInputs = [
        pkgs.android-tools
        pkgs.gnugrep
        pkgs.libnotify
        pkgs.scrcpy
        pkgs.systemd
      ];
      text = ''
        set -uo pipefail

        log() { ${log} "$@"; }

        CACHE_FILE="${CACHE_FILE}"
        ADB_TIMEOUT="${toString ADB_TIMEOUT}"
        PHONE_MODEL="${PHONE_MODEL}"

        # Quick connection validation
        quick_connect() {
          local addr="$1"

          local connect_output
          connect_output=$(timeout "$ADB_TIMEOUT" adb connect "$addr" 2>&1) || return 1

          if echo "$connect_output" | grep -qE "(failed|unable|cannot)"; then
            return 1
          fi

          timeout "$ADB_TIMEOUT" adb -s "$addr" get-state 2>/dev/null | grep -q "device"
        }

        # Trigger the phone-connect service and wait for result
        run_discovery() {
          systemctl --user start phone-connect.service

          # Read updated cache
          if [[ -f "$CACHE_FILE" ]]; then
            cat "$CACHE_FILE" 2>/dev/null
          fi
        }

        main() {
          local addr=""

          # Try cached address first (fast path)
          if [[ -f "$CACHE_FILE" ]]; then
            addr=$(cat "$CACHE_FILE" 2>/dev/null || true)
          fi

          if [[ -n "$addr" ]]; then
            log info "trying cached address: $addr"

            if quick_connect "$addr"; then
              log info "cached connection valid, launching scrcpy"
              notify-send -i phone "Phone Mirror" "Mirroring: $PHONE_MODEL" -u low -t 2000
            else
              log warn "cached address stale, triggering discovery service"
              notify-send -i phone "Phone Mirror" "Searching for phone..." -u normal

              addr=$(run_discovery)

              if [[ -z "$addr" ]]; then
                log error "phone discovery failed"
                notify-send -i phone "Phone Mirror" "Phone not found. Is wireless debugging enabled?" -u critical
                exit 1
              fi

              log info "discovery successful: $addr"
              notify-send -i phone "Phone Mirror" "Found: $addr" -u low -t 2000
            fi
          else
            # No cache - trigger discovery service
            log info "no cached address, triggering discovery service"
            notify-send -i phone "Phone Mirror" "Searching for phone..." -u normal

            addr=$(run_discovery)

            if [[ -z "$addr" ]]; then
              log error "phone discovery failed"
              notify-send -i phone "Phone Mirror" "Phone not found. Is wireless debugging enabled?" -u critical
              exit 1
            fi

            log info "discovery successful: $addr"
            notify-send -i phone "Phone Mirror" "Found: $addr" -u low -t 2000
          fi

          # Launch scrcpy
          log info "launching scrcpy for $addr"
          exec scrcpy \
            --serial "$addr" \
            --render-driver=opengl \
            --video-codec=h264 --video-encoder=c2.exynos.h264.encoder \
            --audio-codec=opus --audio-encoder=c2.android.opus.encoder \
            -m 1200 \
            --print-fps \
            --window-title="$PHONE_MODEL" \
            --stay-awake \
            --turn-screen-off \
            --power-off-on-close \
            --window-borderless
        }

        main
      '';
    };
  in {
    home.packages = [
      phone-connect
      phone-connect-service
      phone-mirror
    ];

    systemd.user.services.phone-connect = {
      Unit = {
        Description = "Phone connection keepalive";
        After = ["network.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${phone-connect-service}/bin/phone-connect-service";
      };
    };

    systemd.user.timers.phone-connect = {
      Unit = {
        Description = "Phone connection keepalive timer";
      };
      Timer = {
        OnBootSec = "10s";
        OnUnitActiveSec = "30s";
        Unit = "phone-connect.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
