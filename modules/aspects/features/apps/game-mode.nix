{
  den.aspects.extra.provides.game-mode.nixos = {
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
  in {
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
