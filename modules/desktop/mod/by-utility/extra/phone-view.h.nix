{pkgs, ...}: let
  PHONE_SERIAL = "46011FDAS009QK";
  CACHE_FILE = "$XDG_RUNTIME_DIR/phone-find-address";

  avahi-browse = "${pkgs.avahi}/bin/avahi-browse";
  rg = "${pkgs.ripgrep}/bin/rg";
  cat = "${pkgs.coreutils}/bin/cat";
  rm = "${pkgs.coreutils}/bin/rm";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  scrcpy = "${pkgs.scrcpy}/bin/scrcpy";
  adb = "${pkgs.android-tools}/bin/adb";
  gum = "${pkgs.gum}/bin/gum";
  logger = "${pkgs.util-linux}/bin/logger";

  log = pkgs.writeShellScript "log" ''
    level="$1"
    shift
    message="$*"

    ${gum} log --level "$level" "$message"
    ${logger} -p "user.$level" -t "$(basename "$0")" "$message"
  '';

  phone-find = pkgs.writeShellScriptBin "phone-find" ''
    set -uo pipefail

    log(){ ${log} "$@"; }

    SERIAL="${PHONE_SERIAL}"
    CACHE_FILE="${CACHE_FILE}"

    log info "starting phone-find daemon, looking for $SERIAL"

    ${avahi-browse} -rp _adb-tls-connect._tcp 2>/dev/null | while IFS=';' read -r event iface proto name stype domain hostname ip port txt; do
      # skip non-relevant lines
      [[ -z "$event" ]] && continue

      # filter for our device
      if ! echo "$name" | ${rg} -q "$SERIAL"; then
        continue
      fi

      # only care about IPv4
      if [[ "$proto" != "IPv4" ]]; then
        continue
      fi

      case "$event" in
        "=")
          # device resolved - write to cache
          log info "phone found: $ip:$port"
          echo "$ip:$port" > "$CACHE_FILE"
          ;;
        "-")
          # device left - remove cache
          log info "phone left network"
          ${rm} -f "$CACHE_FILE"
          ;;
      esac
    done

    log error "avahi-browse exited unexpectedly"
    exit 1
  '';

  phone-mirror = pkgs.writeShellScriptBin "phone-mirror" ''
    set -euo pipefail

    log(){ ${log} "$@"; }

    CACHE_FILE="${CACHE_FILE}"

    if [[ ! -f "$CACHE_FILE" ]]; then
      log error "phone not on network (no cache file)"
      ${notify-send} "Phone Mirror" "Phone not found on network" -u critical
      exit 1
    fi

    CONNECTION=$(${cat} "$CACHE_FILE")

    if [[ -z "$CONNECTION" ]]; then
      log error "phone not on network (empty cache)"
      ${notify-send} "Phone Mirror" "Phone not found on network" -u critical
      exit 1
    fi

    log info "connecting to $CONNECTION"

    ${adb} connect "$CONNECTION" || {
      log error "failed to connect to $CONNECTION"
      ${notify-send} "Phone Mirror" "Failed to connect to $CONNECTION" -u critical
      exit 1
    }

    log info "launching scrcpy"

    ${scrcpy} \
      --serial "$CONNECTION" \
      --render-driver=opengl \
      --video-codec=h264 --video-encoder=c2.exynos.h264.encoder \
      --audio-codec=opus --audio-encoder=c2.android.opus.encoder \
      -m 1200 \
      --print-fps \
      --window-title="google p9p-xl" \
      --stay-awake \
      --turn-screen-off \
      --power-off-on-close
  '';
in {
  home.packages = [
    phone-find
    phone-mirror
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, P, exec, ${phone-mirror}/bin/phone-mirror"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class \\.scrcpy\\-wrapped";
  in [
    "opacity 1.0 override 1.0 override, ${match_}"
    "float on, ${match_}"
    "pin on, ${match_}"
    "move cursor -50% 0, ${match_}"
  ];

  systemd.user.services.phone-find = {
    Unit = {
      Description = "Phone discovery daemon (avahi mDNS)";
      After = ["network.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${phone-find}/bin/phone-find";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
