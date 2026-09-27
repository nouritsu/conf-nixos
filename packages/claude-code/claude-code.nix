{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # Claude spark from simple-icons (CC0), filled in Claude's orange and
    # rasterised so any notification daemon can show it.
    icon =
      pkgs.runCommand "claude-icon.png" {
        src = pkgs.fetchurl {
          url = "https://cdn.jsdelivr.net/npm/simple-icons@16.33.0/icons/claude.svg";
          hash = "sha256-LW/aeesY3czKNbeZ7rPOzg36vCJSDOOxCr0lZo35+pM=";
        };
        nativeBuildInputs = [pkgs.librsvg];
      } ''
        sed 's|<path |<path fill="#D97757" |' $src | rsvg-convert -w 256 -h 256 -o $out
      '';

    # Desktop ping when claude blocks on input or finishes a turn; DMS shows it.
    # Skipped while the terminal running this claude is the focused niri
    # window, found by walking our own ancestry for the focused window's pid.
    # niri comes from the session's PATH; without it (tty, ssh) always notify.
    notify = pkgs.writeShellApplication {
      name = "claude-notify";
      runtimeInputs = [pkgs.jq pkgs.libnotify pkgs.procps];
      text = ''
        input=$(cat)

        focused=$(niri msg --json focused-window 2>/dev/null | jq -r '.pid // empty') || true
        if [[ -n $focused ]]; then
          pid=$$
          while ((pid > 1)); do
            [[ $pid == "$focused" ]] && exit 0
            pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
          done
        fi

        project=$(basename "$(jq -r '.cwd' <<<"$input")")
        case "$(jq -r '.hook_event_name' <<<"$input")" in
          Stop) body="Finished" ;;
          *) body=$(jq -r '.message // "Needs your input"' <<<"$input") ;;
        esac
        notify-send --app-name="Claude Code" --icon=${icon} "Claude Code · $project" "$body"
      '';
    };

    # alejandra over any .nix file claude edits; never blocks the edit, nil
    # already reports syntax errors back to claude.
    nix-format = pkgs.writeShellApplication {
      name = "claude-nix-format";
      runtimeInputs = [pkgs.jq pkgs.alejandra];
      text = ''
        file=$(jq -r '.tool_input.file_path // empty')
        [[ $file == *.nix && -f $file ]] || exit 0
        alejandra --quiet "$file" || true
      '';
    };

    # Local plugin in place of the marketplace *-lsp ones, with servers at
    # store paths instead of whatever is on PATH. Only one server may own an
    # extension, so .nix gets nil (not nixd).
    lsp-plugin = pkgs.writeTextDir ".claude-plugin/plugin.json" (builtins.toJSON {
      name = "nix-lsp";
      description = "Language servers pinned by the NixOS config";
      lspServers = {
        nil = {
          command = lib.getExe pkgs.nil;
          extensionToLanguage.".nix" = "nix";
        };
        rust-analyzer = {
          command = lib.getExe pkgs.rust-analyzer;
          extensionToLanguage.".rs" = "rust";
        };
        clangd = {
          command = "${pkgs.clang-tools}/bin/clangd";
          args = ["--background-index"];
          extensionToLanguage = {
            ".c" = "c";
            ".h" = "c";
            ".cpp" = "cpp";
            ".cc" = "cpp";
            ".cxx" = "cpp";
            ".hpp" = "cpp";
            ".hxx" = "cpp";
          };
        };
      };
    });
  in {
    # Everything here rides in on --settings, which outranks ~/.claude/settings.json.
    # model, effortLevel, tui and enabledPlugins stay out so /model, /effort and
    # /config keep sticking.
    packages.claude-code = wrappers.wrappers.claude-code.wrap [
      {
        inherit pkgs;
        package = pkgs.claude-code;
      }
      {
        mcpConfig = {
          nixos = {
            type = "stdio";
            command = lib.getExe pkgs.mcp-nixos;
          };
          context7 = {
            type = "http";
            url = "https://mcp.context7.com/mcp";
          };
        };

        pluginDirs = [lsp-plugin];

        settings = {
          attribution = {
            commit = "";
            pr = "";
          };

          statusLine = {
            type = "command";
            command = "${lib.getExe pkgs.claude-powerline} --theme=tokyo-night --style=powerline";
          };

          # read-only, so safe in every project; merges with project allows
          permissions.allow = [
            "Bash(nix eval *)"
            "Bash(nix flake show *)"
            "Bash(nix flake metadata *)"
            "Bash(journalctl *)"
            "mcp__nixos"
            "mcp__context7"
          ];

          hooks = {
            Notification = [
              {
                matcher = "permission_prompt|idle_prompt";
                hooks = [
                  {
                    type = "command";
                    command = lib.getExe notify;
                    async = true;
                  }
                ];
              }
            ];
            Stop = [
              {
                hooks = [
                  {
                    type = "command";
                    command = lib.getExe notify;
                    async = true;
                  }
                ];
              }
            ];
            PostToolUse = [
              {
                matcher = "Edit|Write|MultiEdit";
                hooks = [
                  {
                    type = "command";
                    command = lib.getExe nix-format;
                  }
                ];
              }
            ];
          };
        };
      }
    ];
  };
}
