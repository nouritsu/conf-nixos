{
  den.aspects.extra.provides.game-mode.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: let
    # games stasis detects go to gamemode, no gamemoderun in launch options
    watch = pkgs.writeShellApplication {
      name = "game-mode-watch";
      runtimeInputs = [pkgs.stasis pkgs.jq pkgs.systemd];
      text = ''
        declare -A registered=()

        check() {
          local info pid
          info=$(stasis info --json 2> /dev/null) || return 0
          for pid in $(jq -r '.games.running[]?.pids[]?' <<< "$info"); do
            [[ -v "registered[$pid]" ]] && continue
            busctl --user call com.feralinteractive.GameMode /com/feralinteractive/GameMode \
              com.feralinteractive.GameMode RegisterGameByPID ii $$ "$pid" > /dev/null && registered[$pid]=1
          done
          # gamemode drops exited games itself
          for pid in "''${!registered[@]}"; do
            kill -0 "$pid" 2> /dev/null || unset "registered[$pid]"
          done
        }

        # on every stasis state change, else every 5 s
        exec {events}< <(stasis watch)
        while :; do
          check
          rc=0
          read -r -t 5 -u "$events" _ || rc=$?
          # eof: stasis stopped, the unit restarts
          ((rc == 0 || rc > 128)) || exit 1
        done
      '';
    };

    # gamemode runs these with only pkexec on its path
    hook = pkgs.writeShellApplication {
      name = "game-mode-hook";
      runtimeInputs = [
        config.programs.dux-shell.package
        config.services.power-profiles-daemon.package
        pkgs.systemd
        pkgs.coreutils
      ];
      text = ''
        dir=''${XDG_RUNTIME_DIR:?}/game-mode
        mkdir -p "$dir"

        on_battery() {
          [[ $(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2> /dev/null) == "b true" ]]
        }

        case $1 in
          start)
            # only a dnd that was off is switched back
            if [[ $(dms ipc call notifications getDoNotDisturb) == false ]] &&
              dms ipc call notifications enableDoNotDisturbIndefinitely > /dev/null; then
              touch "$dir/dnd"
            fi
            # laptops on battery keep their profile
            if ! on_battery && profile=$(powerprofilesctl get) && [[ $profile != performance ]] &&
              powerprofilesctl set performance; then
              printf '%s\n' "$profile" > "$dir/profile"
            fi
            ;;
          end)
            if [[ -e $dir/dnd ]] && dms ipc call notifications disableDoNotDisturb > /dev/null; then
              rm "$dir/dnd"
            fi
            if [[ -s $dir/profile ]] && powerprofilesctl set "$(< "$dir/profile")"; then
              rm "$dir/profile"
            fi
            ;;
        esac
      '';
    };
  in {
    programs.gamemode.settings = {
      # cap_sys_nice comes from the module's wrapper; stay out of the gamemode
      # group, its governor helper would fight ppd's profile
      general.renice = 10;

      custom = {
        start = "${lib.getExe hook} start";
        end = "${lib.getExe hook} end";
      };
    };

    systemd.user.services.game-mode = {
      description = "Register running games with gamemode";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target" "stasis.service"];
      serviceConfig = {
        ExecStart = lib.getExe watch;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
