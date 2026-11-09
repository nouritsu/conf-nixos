{
  # on every host, so any aspect can give way to games
  den.default.nixos = {lib, ...}: {
    # system units stopped while a game runs, and started again after
    options.game-mode'.pauses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  den.aspects.extra.provides.game-mode.nixos = {
    config,
    host,
    self',
    pkgs,
    lib,
    ...
  }: let
    gamemode = "com.feralinteractive.GameMode /com/feralinteractive/GameMode com.feralinteractive.GameMode";
    owner = lib.head (lib.attrNames host.users);
    inherit (config.game-mode') pauses;

    # games stasis detects go to gamemode, no gamemoderun in launch options
    watch = pkgs.writeShellApplication {
      name = "game-mode-watch";
      runtimeInputs = [pkgs.stasis pkgs.jq pkgs.systemd pkgs.gnugrep];
      text = ''
        dir=''${XDG_RUNTIME_DIR:?}/game-mode
        declare -A registered=()

        check() {
          local info pid
          info=$(stasis info --json 2> /dev/null) || return 0
          for pid in $(jq -r '.games.running[]?.pids[]?' <<< "$info"); do
            # toggled off until the game exits
            if grep -qsx "$pid" "$dir/off"; then
              unset "registered[$pid]"
              continue
            fi
            [[ -v "registered[$pid]" ]] && continue
            busctl --user call ${gamemode} RegisterGameByPID ii $$ "$pid" > /dev/null && registered[$pid]=1
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
            # only the units that were running come back
            units=(${lib.escapeShellArgs pauses})
            for unit in "''${units[@]}"; do
              if systemctl is-active --quiet "$unit" && systemctl stop --no-block "$unit"; then
                echo "$unit" >> "$dir/paused"
              fi
            done
            # the bar's icon
            echo 1 > "$dir/active"
            ;;
          end)
            if [[ -e $dir/dnd ]] && dms ipc call notifications disableDoNotDisturb > /dev/null; then
              rm "$dir/dnd"
            fi
            if [[ -s $dir/profile ]] && powerprofilesctl set "$(< "$dir/profile")"; then
              rm "$dir/profile"
            fi
            if [[ -s $dir/paused ]] && mapfile -t units < "$dir/paused" && systemctl start --no-block "''${units[@]}"; then
              rm "$dir/paused"
            fi
            echo 0 > "$dir/active"
            ;;
        esac
      '';
    };

    # off: every running game until it exits; on: a held sleep stands in for a game
    toggle = pkgs.writeShellApplication {
      name = "game-mode-toggle";
      runtimeInputs = [pkgs.systemd pkgs.jq pkgs.coreutils];
      text = ''
        dir=''${XDG_RUNTIME_DIR:?}/game-mode
        mkdir -p "$dir"

        systemctl --user stop game-mode-hold.service 2> /dev/null || true

        if [[ $(cat "$dir/active" 2> /dev/null) == 1 ]]; then
          for pid in $(busctl --user --json=short call ${gamemode} ListGames | jq -r '.data[0][][0]'); do
            echo "$pid" >> "$dir/off"
            busctl --user call ${gamemode} UnregisterGameByPID ii $$ "$pid" > /dev/null
          done
        else
          rm -f "$dir/off"
          systemd-run --user --unit=game-mode-hold --collect --quiet ${lib.getExe' pkgs.coreutils "sleep"} infinity
          busctl --user call ${gamemode} RegisterGameByPID ii $$ \
            "$(systemctl --user show -p MainPID --value game-mode-hold.service)" > /dev/null
        fi
      '';
    };
  in {
    environment.systemPackages = [toggle];

    # the hook runs as the owner; no prompt for exactly these units
    security.polkit.extraConfig = lib.mkIf (pauses != []) ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            ${builtins.toJSON pauses}.indexOf(action.lookup("unit")) >= 0 &&
            ["start", "stop"].indexOf(action.lookup("verb")) >= 0 &&
            subject.user == "${owner}" && subject.local && subject.active)
          return polkit.Result.YES;
      });
    '';

    # exists before Dux's widget watches it
    systemd.user.tmpfiles.rules = [
      "d %t/game-mode 0700 - - -"
      "f %t/game-mode/active - - - - 0"
    ];

    programs.dux-shell.plugins.gameMode = {
      enable = true;
      src = self'.packages.dux-game-mode;
    };

    which-key'.menu.g.submenu.t = {
      desc = "Game mode";
      icon = "f0297";
      cmd = lib.getExe toggle;
    };

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
