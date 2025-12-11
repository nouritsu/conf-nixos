{pkgs, ...}: let
  wallpaper_dir = "$NH_FLAKE/modules/de/wallpapers";

  swww = "${pkgs.swww}/bin/swww";
  gum = "${pkgs.gum}/bin/gum";
  logger = "${pkgs.util-linux}/bin/logger";
  fd = "${pkgs.fd}/bin/fd";

  log = pkgs.writeShellScript "log" ''
    level="$1"
    shift
    message="$*"

    ${gum} log --level "$level" "$message"
    ${logger} -p "user.$level" -t "$(basename "$0")" "$message"
  '';

  change_wall = pkgs.writeShellScriptBin "swww-change-wallpaper" ''
    log(){ ${log} "$@"; }

    dir="${wallpaper_dir}"
    dir=$(eval echo "$dir")

    if [[ ! -d "$dir" ]]; then
      log error "wallpaper directory not found: $dir"
      exit 1
    fi

    mapfile -t wallpapers < <(${fd} -e png -e jpg -e jpeg -e gif -e webp . "$dir" --type f)

    if [[ ''${#wallpapers[@]} -eq 0 ]]; then
      log error "wallpaper directory is empty: $dir"
      exit 1
    fi

    selected="''${wallpapers[RANDOM % ''${#wallpapers[@]}]}"

    log info "setting wallpaper: $selected"
    ${swww} img $selected \
    --transition-type grow \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-pos 0.85,0.95
  '';
in {
  home.packages = [change_wall];

  services.swww = {
    enable = true;
    package = pkgs.swww;
  };

  systemd.user.services.swww-change-wallpaper = {
    Unit = {
      Description = "";
      After = ["swww.service"];
      Requires = ["swww.service"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${change_wall}/bin/swww-change-wallpaper";
    };
  };

  systemd.user.timers.swww-change-wallpaper = {
    Unit = {
      Description = "";
      After = ["swww.service"];
    };
    Timer = {
      OnActiveSec = "5s";
      OnUnitActiveSec = "30m";
      Unit = "swww-change-wallpaper.service";
    };
    Install.WantedBy = ["timers.target"];
  };
}
