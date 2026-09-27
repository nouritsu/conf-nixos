{
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    # GDScript's language server lives inside the Godot editor and speaks TCP;
    # editors and AI tools want a stdio command. This bridges the two for the
    # project at or below the working directory: through the open editor when
    # it has that project, otherwise through a private headless editor that
    # lives as long as the bridge.
    packages.godot-lsp = pkgs.writeShellApplication {
      name = "godot-lsp";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnused
        pkgs.iproute2
        pkgs.socat
        pkgs.util-linux
      ];
      text = ''
        start=$(realpath "''${CLAUDE_PROJECT_DIR:-$PWD}")

        root=""
        dir=$start
        while :; do
          if [[ -f $dir/project.godot ]]; then root=$dir; break; fi
          [[ $dir == / ]] && break
          dir=''${dir%/*}; dir=''${dir:-/}
        done
        if [[ -z $root ]]; then
          root=$(find "$start" -mindepth 1 -maxdepth 4 \( -name '.*' -o -name addons \) -prune \
            -o -name project.godot -printf '%d %h\n' 2>/dev/null | sort -n | head -n1 | cut -d' ' -f2-)
        fi
        if [[ -z $root ]]; then
          echo "godot-lsp: no project.godot at, above or below $start" >&2
          exit 1
        fi

        # Which project an editor process has open: the project manager starts
        # editors with --path, a shell may pass project.godot or just cd there.
        project_of() {
          local pid=$1 cwd prev="" arg
          cwd=$(readlink "/proc/$pid/cwd") || return 1
          while IFS= read -r -d "" arg; do
            if [[ $prev == --path ]]; then
              (cd "$cwd" && realpath "$arg"); return
            fi
            if [[ $arg == *project.godot ]]; then
              (cd "$cwd" && realpath "$(dirname "$arg")"); return
            fi
            prev=$arg
          done <"/proc/$pid/cmdline"
          echo "$cwd"
        }

        port=''${GODOT_LSP_PORT:-6005}
        pid=$(ss -Htlnp "sport = :$port" | sed -nE 's/.*pid=([0-9]+).*/\1/p' | head -n1)
        if [[ -n $pid && $(project_of "$pid") == "$root" ]]; then
          exec socat STDIO "TCP:127.0.0.1:$port"
        fi

        # Its own config, data and cache, so this editor never saves over the
        # settings of one you open later. The project's .godot/ is shared.
        state=''${XDG_STATE_HOME:-$HOME/.local/state}/godot-lsp
        mkdir -p "$state"
        port=$(shuf -i 20000-60999 -n 1)
        while [[ -n $(ss -Htln "sport = :$port") ]]; do port=$(shuf -i 20000-60999 -n 1); done

        # Godot from PATH, so a project's devShell picks the version; this
        # config's Godot when there is none.
        godot=$(command -v godot || echo ${lib.getExe self'.packages.godot})

        # pdeathsig: the editor goes when this script does, however it goes
        XDG_CONFIG_HOME=$state/config XDG_DATA_HOME=$state/data XDG_CACHE_HOME=$state/cache \
          setpriv --pdeathsig TERM -- "$godot" --headless --editor --path "$root" --lsp-port "$port" \
          >"$state/''${root//\//_}.log" 2>&1 &
        editor=$!
        trap 'kill "$editor" 2>/dev/null' EXIT

        # the port opens once the first filesystem scan and import are done
        until [[ -n $(ss -Htln "sport = :$port") ]]; do
          if ! kill -0 "$editor" 2>/dev/null; then
            echo "godot-lsp: headless editor for $root exited; see $state/''${root//\//_}.log" >&2
            exit 1
          fi
          sleep 0.5
        done
        socat STDIO "TCP:127.0.0.1:$port"
      '';
    };
  };
}
