{
  perSystem = {pkgs, ...}: {
    # sigkills the focused window's process; a steam game's whole tree
    packages.force-quit = pkgs.writeShellApplication {
      name = "force-quit";
      runtimeInputs = [pkgs.niri pkgs.jq pkgs.procps pkgs.xprop pkgs.gnused pkgs.libnotify];
      text = ''
        win=$(niri msg --json focused-window)
        app=$(jq -r '.app_id // ""' <<< "$win")
        pid=$(jq -r '.pid // empty' <<< "$win")
        [[ -n $pid ]] || exit 0

        tree() {
          local child
          echo "$1"
          for child in $(pgrep -P "$1"); do
            tree "$child"
          done
        }

        if [[ $app =~ ^steam_app_([0-9]+)$ ]]; then
          # steam runs each game under a reaper carrying its app id
          reaper=$(pgrep -f "reaper SteamLaunch AppId=''${BASH_REMATCH[1]} " | head -n 1) || reaper=
          if [[ -n $reaper ]]; then
            mapfile -t pids < <(tree "$reaper")
            exec kill -KILL "''${pids[@]}"
          fi
        fi

        # x11 windows all report xwayland-satellite; x knows the client's pid
        if [[ $(ps -o comm= -p "$pid") == *xwayland-sat* ]]; then
          xid=$(xprop -root _NET_ACTIVE_WINDOW | sed -n 's/.*# \(0x[0-9a-f]*\).*/\1/p')
          pid=$(xprop -id "$xid" _NET_WM_PID | sed -n 's/.* = \([0-9]*\)$/\1/p')
        fi

        if [[ -z $pid ]]; then
          notify-send "Force quit" "No process found for $app"
          exit 1
        fi
        exec kill -KILL "$pid"
      '';
    };
  };
}
