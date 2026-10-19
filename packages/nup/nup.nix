{inputs, ...}: let
  inherit (inputs.nix-colors.colorSchemes.catppuccin-mocha) palette;
in {
  perSystem = {pkgs, ...}: let
    # top-level inputs whose locked source differs from the old lock
    changedInputs = pkgs.writeText "changed-inputs.jq" ''
      def locked($lock; $name):
        $lock.nodes.root.inputs[$name] as $node
        | if ($node | type) == "string" then $lock.nodes[$node].locked else null end;
      . as $new | .nodes.root.inputs | keys[] | select(locked($new; .) != locked($old[0]; .))
    '';
  in {
    # update inputs and pins in a scratch worktree, commit only if every host builds
    packages.nup = pkgs.writeShellApplication {
      name = "nup";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.dix
        pkgs.gum
        pkgs.jq
        pkgs.nix-output-monitor
        pkgs.nix-update
      ];
      text = ''
        flake=''${NH_FLAKE:-$HOME/.config/nixos}
        system=${pkgs.stdenv.hostPlatform.system}
        host=$(uname -n)

        # the worktree is dirty from the first edit on
        printf -v NIX_CONFIG 'warn-dirty = false\n%s' "''${NIX_CONFIG-}"
        export NIX_CONFIG

        export GUM_SPIN_SPINNER_FOREGROUND="#${palette.base0E}"
        export GUM_TABLE_BORDER_FOREGROUND="#${palette.base0E}"
        export GUM_TABLE_HEADER_FOREGROUND="#${palette.base0E}"
        export GUM_CONFIRM_PROMPT_FOREGROUND="#${palette.base0E}"
        export GUM_CONFIRM_SELECTED_BACKGROUND="#${palette.base0E}"
        export GUM_CONFIRM_SELECTED_FOREGROUND="#${palette.base00}"
        export GUM_CONFIRM_UNSELECTED_BACKGROUND="#${palette.base02}"
        export GUM_CONFIRM_UNSELECTED_FOREGROUND="#${palette.base05}"

        step=""
        stage() {
          step="$1/5 $2"
          gum style --bold --foreground "#${palette.base0E}" --border rounded --border-foreground "#${palette.base0E}" --padding "0 1" "$step"
        }
        log() {
          gum log --level "$1" "$2"
        }

        reported=""
        cleanup() {
          status=$?
          if ((status)) && [[ -z $reported ]]; then
            log error "Failed at $step, nothing landed"
          fi
          git -C "$flake" worktree remove --force "$tree" 2>/dev/null || true
          rm -rf "$work"
        }

        stage 1 "Updating inputs"
        git -C "$flake" worktree prune
        base=$(git -C "$flake" rev-parse HEAD)
        work=$(mktemp -d -t nup.XXXXXX)
        tree=$work/tree
        trap cleanup EXIT

        git -C "$flake" worktree add --quiet --detach "$tree" "$base"
        cd "$tree"
        log info "Worktree at $(git rev-parse --short HEAD)"

        cp flake.lock "$work/old.lock"
        gum spin --show-error --title "nix flake update" -- nix flake update
        mapfile -t inputs < <(jq -r --slurpfile old "$work/old.lock" -f ${changedInputs} flake.lock)
        joined=""
        if ((''${#inputs[@]})); then
          printf -v joined '%s, ' "''${inputs[@]}"
          joined=''${joined%, }
          log info "Updated ''${#inputs[@]}: $joined"
        else
          log info "No input changed"
        fi

        stage 2 "Bumping pins"
        # pins are packages with passthru.nup, a list of extra nix-update args
        gum spin --show-stdout --show-error --title "Finding pins" -- nix eval --json ".#packages.$system" --apply '
          ps: builtins.listToAttrs (builtins.concatMap (n: let
            p = builtins.getAttr n ps;
          in
            if p ? nup then [{name = n; value = p.nup;}] else []) (builtins.attrNames ps))
        ' >"$work/pins.json"
        mapfile -t pins < <(jq -r 'to_entries[] | [.key] + .value | join(" ")' "$work/pins.json")

        # nix-update writes "attr: old -> new", new is None for --version=skip
        bump='^[^:]+: (.*) -> (.*)$'
        rows=()
        for line in "''${pins[@]}"; do
          read -r -a pin <<<"$line"
          before=$(git diff | cksum)
          gum spin --show-error --title "Bumping ''${pin[0]}" -- nix-update --flake --write-commit-message "$work/msg" "''${pin[@]:1}" "''${pin[0]}"
          if [[ $(git diff | cksum) != "$before" ]]; then
            from="?"
            to="?"
            if [[ $(head -n1 "$work/msg") =~ $bump ]]; then
              from=''${BASH_REMATCH[1]}
              to=''${BASH_REMATCH[2]}
            fi
            if [[ $to == None ]]; then
              to=hashes
            fi
            rows+=("''${pin[0]},$from,$to")
            log info "''${pin[0]} $from → $to"
          fi
        done
        log info "''${#rows[@]} of ''${#pins[@]} pins bumped"

        gum spin --show-error --title "nix fmt" -- nix fmt
        if [[ -z $(git status --porcelain) ]]; then
          log info "Already up to date"
          exit 0
        fi

        gum spin --show-stdout --show-error --title "Listing hosts" -- nix eval --json .#nixosConfigurations --apply builtins.attrNames >"$work/hosts.json"
        mapfile -t hosts < <(jq -r '.[]' "$work/hosts.json")
        targets=()
        for h in "''${hosts[@]}"; do
          targets+=(".#nixosConfigurations.$h.config.system.build.toplevel")
        done

        build_review() {
          stage 3 "Building ''${hosts[*]}"
          { nix build --keep-going --no-link --json --log-format internal-json -v "''${targets[@]}" >"$work/built.json"; } 2>&1 | nom --json

          stage 4 "Reviewing"
          if [[ -n $joined ]]; then
            log info "Inputs: $joined"
          fi
          if ((''${#rows[@]})); then
            printf '%s\n' "''${rows[@]}" | gum table --print --columns "Pin,From,To"
          fi
          : >"$work/diff"
          for i in "''${!hosts[@]}"; do
            if [[ ''${hosts[$i]} == "$host" ]]; then
              new=$(jq -r ".[$i].outputs.out" "$work/built.json")
              dix /run/current-system "$new"
              dix --color never /run/current-system "$new" >"$work/diff"
            fi
          done
          if ! gum confirm --default "Commit this update?"; then
            log warn "Discarded, nothing landed"
            exit 0
          fi
        }

        write_commit() {
          {
            echo "chore(flake): update inputs"
            echo
            if [[ -n $joined ]]; then
              echo "inputs: $joined"
              echo
            fi
            if ((''${#rows[@]})); then
              for row in "''${rows[@]}"; do
                IFS=, read -r name from to <<<"$row"
                echo "$name: $from -> $to"
              done
              echo
            fi
            if [[ -s $work/diff ]]; then
              echo "$host closure:"
              cat "$work/diff"
            fi
          } >"$work/commit"
        }

        build_review
        stage 5 "Committing"
        write_commit
        git add -A
        git commit --quiet --no-verify --file "$work/commit"

        # what was built must be what lands, so replay onto a moved HEAD and build again
        while head=$(git -C "$flake" rev-parse HEAD) && [[ $head != "$base" ]]; do
          log warn "HEAD moved to ''${head:0:7} while nup ran, rebuilding on it"
          update=$(git rev-parse HEAD)
          git reset --quiet --hard "$head"
          if ! git cherry-pick "$update" >/dev/null 2>&1; then
            git cherry-pick --abort 2>/dev/null || true
            git -C "$flake" branch --force nup "$update"
            reported=1
            log error "The update conflicts with ''${head:0:7}, it's on branch nup"
            exit 1
          fi
          base=$head
          build_review
          stage 5 "Committing"
          write_commit
          git commit --quiet --no-verify --amend --file "$work/commit"
        done

        update=$(git rev-parse HEAD)
        if ! git -C "$flake" merge --quiet --ff-only "$update"; then
          git -C "$flake" branch --force nup "$update"
          reported=1
          log error "Couldn't fast-forward $(git -C "$flake" branch --show-current), the update is on branch nup"
          exit 1
        fi
        log info "Landed $(git -C "$flake" rev-parse --short HEAD) on $(git -C "$flake" branch --show-current), switch when ready"
      '';
    };
  };
}
