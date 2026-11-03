{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {pkgs, ...}: {
    # pin dux's live settings into the repo, commit once every host builds
    packages.dux-freeze = pkgs.writeShellApplication {
      name = "dux-freeze";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.dyff
        pkgs.gnugrep
        pkgs.gum
        pkgs.jq
        pkgs.nix-output-monitor
      ];
      text = ''
        flake=''${NH_FLAKE:-$HOME/.config/nixos}
        host=$(uname -n)
        dir=''${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell
        settings=modules/aspects/features/desktop/dux-settings.json
        plugins=modules/aspects/features/desktop/dux-plugin-settings.json

        export GUM_SPIN_SPINNER_FOREGROUND="#${palette.base0E}"
        export GUM_CONFIRM_PROMPT_FOREGROUND="#${palette.base0E}"
        export GUM_CONFIRM_SELECTED_BACKGROUND="#${palette.base0E}"
        export GUM_CONFIRM_SELECTED_FOREGROUND="#${palette.base00}"
        export GUM_CONFIRM_UNSELECTED_BACKGROUND="#${palette.base02}"
        export GUM_CONFIRM_UNSELECTED_FOREGROUND="#${palette.base05}"

        step=""
        stage() {
          step="$1/4 $2"
          gum style --bold --foreground "#${palette.base0E}" --border rounded --border-foreground "#${palette.base0E}" --padding "0 1" "$step"
        }
        log() {
          gum log --level "$1" "$2"
        }

        reported=""
        fail() {
          log error "$1"
          reported=1
          exit 1
        }

        # until it lands, the repo files go back to how they were
        landed=""
        cleanup() {
          status=$?
          if [[ -z $landed && -f $work/settings.old ]]; then
            cp "$work/settings.old" "$settings"
            cp "$work/plugins.old" "$plugins"
          fi
          if ((status)) && [[ -z $reported ]]; then
            log error "Failed at $step, the repo is as it was"
          fi
          rm -rf "$work"
        }

        cd "$flake"
        work=$(mktemp -d -t dux-freeze.XXXXXX)
        trap cleanup EXIT

        stage 1 "Reading Dux"
        if ! git diff --quiet HEAD -- "$settings" "$plugins"; then
          fail "The pinned files have uncommitted changes"
        fi
        if ! dms ipc call settings dump >"$work/live.json" 2>/dev/null || ! jq -e 'type == "object"' "$work/live.json" >/dev/null 2>&1; then
          fail "Couldn't dump Dux's settings, is it running?"
        fi

        # what dux started from at the last switch
        base=$(readlink -f "$dir/settings.json")
        if [[ $base != /nix/store/* ]]; then
          fail "settings.json isn't linked to the store"
        fi
        pin=$(systemctl --user show -P ExecStartPre dms.service | grep -o '/nix/store/[^ ;]*/bin/dux-pin-settings' | head -n1 || true)
        pluginBase=$(grep -o '/nix/store/[^ ]*-dux-plugin-settings.json' "$pin" 2>/dev/null | head -n1 || true)
        if [[ -z $pluginBase ]]; then
          fail "Couldn't find the plugin pins dms.service started with"
        fi

        gum spin --show-stdout --show-error --title "Evaluating $host's settings" -- nix eval --json ".#nixosConfigurations.$host.config.dux'.settings" >"$work/built.json"

        stage 2 "Freezing"
        freeze() {
          jq --arg kind "$1" --slurpfile base "$2" --slurpfile live "$3" --slurpfile built "$work/built.json" -f ${./freeze.jq} "$4"
        }
        freeze settings "$base" "$work/live.json" "$settings" >"$work/settings.out"
        freeze plugins "$pluginBase" "$dir/plugin_settings.json" "$plugins" >"$work/plugins.out"
        jq .settings "$work/settings.out" >"$work/settings.new"
        jq .settings "$work/plugins.out" >"$work/plugins.new"

        while IFS=$'\t' read -r path why; do
          if [[ $why == repo ]]; then
            log warn "$path changed live and in the repo since the last switch, left as is"
          else
            log warn "$path is rewritten by $host's overrides, left as is"
          fi
        done < <(jq -r '.conflicts[] | [(.path | map(tostring) | join(".")), .why] | @tsv' "$work/settings.out" "$work/plugins.out")

        changed=""
        show() {
          if ! cmp -s "$1" "$2"; then
            changed=1
            gum style --bold --foreground "#${palette.base0E}" "$(basename "$1")"
            dyff between --omit-header "$1" "$2"
          fi
        }
        show "$settings" "$work/settings.new"
        show "$plugins" "$work/plugins.new"
        if [[ -z $changed ]]; then
          log info "Nothing to freeze, the repo matches Dux"
          exit 0
        fi

        cp "$settings" "$work/settings.old"
        cp "$plugins" "$work/plugins.old"
        cp "$work/settings.new" "$settings"
        cp "$work/plugins.new" "$plugins"

        gum spin --show-stdout --show-error --title "Listing hosts" -- nix eval --json .#nixosConfigurations --apply builtins.attrNames >"$work/hosts.json"
        mapfile -t hosts < <(jq -r '.[]' "$work/hosts.json")
        targets=()
        for h in "''${hosts[@]}"; do
          targets+=(".#nixosConfigurations.$h.config.system.build.toplevel")
        done

        stage 3 "Building ''${hosts[*]}"
        { nix build --keep-going --no-link --log-format internal-json -v "''${targets[@]}"; } 2>&1 | nom --json

        stage 4 "Committing"
        if ! gum confirm --default "Commit this freeze?"; then
          log warn "Discarded, the repo is as it was"
          exit 0
        fi
        {
          echo "chore(dux): freeze settings"
          echo
          jq -r '[.applied[][0]] | unique | select(length > 0) | "settings: " + join(", ")' "$work/settings.out"
          jq -r '[.applied[] | join(".")] | select(length > 0) | "plugins: " + join(", ")' "$work/plugins.out"
        } >"$work/commit"
        git commit --quiet --no-verify --file "$work/commit" --only -- "$settings" "$plugins"
        landed=1
        log info "Landed $(git rev-parse --short HEAD) on $(git branch --show-current), switch when ready"
      '';
    };
  };
}
