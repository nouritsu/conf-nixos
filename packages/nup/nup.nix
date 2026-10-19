{
  perSystem = {pkgs, ...}: {
    # update inputs and pins in a scratch worktree, commit only if every host builds
    packages.nup = pkgs.writeShellApplication {
      name = "nup";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
        pkgs.jq
        pkgs.nix-update
      ];
      text = ''
        flake=''${NH_FLAKE:-$HOME/.config/nixos}
        system=${pkgs.stdenv.hostPlatform.system}
        host=$(uname -n)

        git -C "$flake" worktree prune
        base=$(git -C "$flake" rev-parse HEAD)
        work=$(mktemp -d -t nup.XXXXXX)
        tree=$work/tree

        cleanup() {
          git -C "$flake" worktree remove --force "$tree" 2>/dev/null || true
          rm -rf "$work"
        }
        trap cleanup EXIT

        git -C "$flake" worktree add --quiet --detach "$tree" "$base"
        cd "$tree"

        echo "nup: updating inputs from $(git rev-parse --short HEAD)" >&2
        nix flake update 2>&1 | tee "$work/inputs.log"
        mapfile -t inputs < <(grep -oP "Updated input '\K[^'/]+(?=':)" "$work/inputs.log")

        # pins are packages with passthru.nup, a list of extra nix-update args
        nix eval --json ".#packages.$system" --apply '
          ps: builtins.listToAttrs (builtins.concatMap (n: let
            p = builtins.getAttr n ps;
          in
            if p ? nup then [{name = n; value = p.nup;}] else []) (builtins.attrNames ps))
        ' >"$work/pins.json"
        mapfile -t pins < <(jq -r 'to_entries[] | [.key] + .value | join(" ")' "$work/pins.json")

        bumped=()
        for line in "''${pins[@]}"; do
          read -r -a pin <<<"$line"
          echo "nup: checking ''${pin[0]}" >&2
          before=$(git diff | cksum)
          nix-update --flake --write-commit-message "$work/msg" "''${pin[@]:1}" "''${pin[0]}"
          if [[ $(git diff | cksum) != "$before" ]]; then
            msg=$(head -n1 "$work/msg")
            if [[ $msg == *" -> None" ]]; then
              msg="''${pin[0]}: dependency hashes"
            fi
            bumped+=("$msg")
          fi
        done

        if [[ -z $(git status --porcelain) ]]; then
          echo "nup: already up to date" >&2
          exit 0
        fi

        mapfile -t hosts < <(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]')
        targets=()
        for h in "''${hosts[@]}"; do
          targets+=(".#nixosConfigurations.$h.config.system.build.toplevel")
        done
        echo "nup: building ''${hosts[*]}" >&2
        nix build --keep-going --no-link --json "''${targets[@]}" >"$work/built.json"

        diff=""
        for i in "''${!hosts[@]}"; do
          if [[ ''${hosts[$i]} == "$host" ]]; then
            diff=$(nix store diff-closures /run/current-system "$(jq -r ".[$i].outputs.out" "$work/built.json")" | sed 's/\x1b\[[0-9;]*m//g')
          fi
        done

        {
          if ((''${#inputs[@]})); then
            printf -v joined '%s, ' "''${inputs[@]}"
            echo "inputs: ''${joined%, }"
            echo
          fi
          if ((''${#bumped[@]})); then
            printf '%s\n' "''${bumped[@]}"
            echo
          fi
          if [[ -n $diff ]]; then
            echo "$host closure:"
            echo "$diff"
          fi
        } >"$work/body"

        # the pre-commit hook is this treefmt
        nix fmt
        git add -A
        printf 'chore(flake): update inputs\n\n' | cat - "$work/body" >"$work/commit"
        git commit --quiet --no-verify --file "$work/commit"
        sha=$(git rev-parse HEAD)

        cd "$flake"
        git branch --quiet --force nup "$sha"
        if git merge --quiet --ff-only nup 2>/dev/null || git cherry-pick nup; then
          git branch --quiet --delete --force nup
        else
          git cherry-pick --abort 2>/dev/null || true
          echo "nup: couldn't land the update on $(git branch --show-current); it's on branch nup" >&2
          exit 1
        fi

        cat "$work/body"
        echo "nup: committed $(git rev-parse --short HEAD), switch when ready" >&2
      '';
    };
  };
}
