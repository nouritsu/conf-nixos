{
  pkgs,
  usrconf,
  inputs,
  waybar_lib,
  ...
}: let
  sig = 8;

  hyprland = inputs.hyprland.packages.${usrconf.system}.hyprland;
  hyprctl = "${hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";
  socat = "${pkgs.socat}/bin/socat";
  gum = "${pkgs.gum}/bin/gum";
  pkill = "${pkgs.procps}/bin/pkill";
  sleep = "${pkgs.coreutils}/bin/sleep";

  scratchpad = pkgs.writeShellScript "waybar-scratchpad" ''
    id=$(${hyprctl} monitors -j | ${jq} -r '.[] | select(.focused) | .specialWorkspace.id')
    class="inactive"
    wc="0"

    if [[ -n "$id" ]] && [[ "$id" -lt 0 ]]; then
      class="active"
      wc=$(${hyprctl} workspaces -j | ${jq} -r --arg id "$id" '.[] | select(.id == ($id | tonumber)) | .windows')
    fi

    echo "{\"class\": \"$class\", \"tooltip\": \"Windows: $wc\"}"
  '';

  listener = pkgs.writeShellScriptBin "waybar-scratchpad-listener" ''
    ${gum} log --level info "fetching hyprland instance signature"
    HYPRLAND_INSTANCE_SIGNATURE=''${HYPRLAND_INSTANCE_SIGNATURE:-$(${hyprctl} instances -j | ${jq} -r '.[0].instance')}

    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      ${gum} log --level fatal "hyprland instance signature not found"
    else
      ${gum} log --level info "hyprland instance signature found"
    fi

    sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    ${gum} log --level info "listening: $sock"
    while true; do
      ${socat} -U - UNIX-CONNECT:"$sock" | grep --line-buffered -E "activespecialv2|workspace>>" | while read -r line; do
          ${gum} log --level debug "event recieved: $line"

          if ${pkill} -SIGRTMIN+${builtins.toString sig} -x .waybar-wrapped; then
            ${gum} log --level info "waybar signalled"
          else
            ${gum} log --level error "could not signal waybar, is it runnning?"
          fi
      done

      ${gum} log --level error "socat crashed/disconnected, retrying in 1s"
      ${sleep} 1
    done
  '';
in {
  programs.waybar.settings.default."custom/scratchpad" = {
    format = "";
    exec = "${scratchpad}";
    return-type = "json";
    signal = sig;
    on-click = "${hyprctl} dispatch togglespecialworkspace magic && pkill -x -SIGRTMIN+${builtins.toString sig} .waybar-wrapped";
    interval = "once";
  };

  systemd.user.services.waybar-scratchpad-listener = {
    Unit = {
      Description = "Listen for Hyprland magic workspace changes and signal waybar if any";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${listener}/bin/waybar-scratchpad-listener";
      Restart = "always";
      RestartSec = "5";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "scratchpad-fg: @crust"
      "scratchpad-bg-active: @surface0"
      "scratchpad-bg-inactive: @accent"
    ];

    parts =
      /*
      css
      */
      ''
        #custom-scratchpad {
          background-color: @scratchpad-bg-inactive;
          color: @scratchpad-fg;
          padding: 0 8px 0 4px;
        }

        #custom-scratchpad.active {
          background-color: @scratchpad-bg-active;
          color: @scratchpad-fg;
        }
      '';
  };
}
