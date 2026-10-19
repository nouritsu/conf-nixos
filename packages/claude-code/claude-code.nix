{inputs, ...}: let
  inherit (inputs) wrappers nix-colors;
  inherit (nix-colors.colorSchemes.catppuccin-mocha) palette;

  c = slot: "#${palette.${slot}}";
  base = c "base00";
  mantle = c "base01";
  surface0 = c "base02";
  surface1 = c "base03";
  surface2 = c "base04";
  text = c "base05";
  lavender = c "base07";
  red = c "base08";
  peach = c "base09";
  yellow = c "base0A";
  green = c "base0B";
  teal = c "base0C";
  blue = c "base0D";
  mauve = c "base0E";
  flamingo = c "base0F";
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    # Claude spark (simple-icons, CC0) in Claude's orange
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

    # notify on input or turn end, unless its terminal is the focused niri window
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
        # --app-icon, not --icon: DMS draws --icon twice
        notify-send --app-name="Claude Code" --app-icon=${icon} "Claude Code · $project" "$body"
      '';
    };

    # alejandra on any .nix claude edits; never blocks the edit
    nix-format = pkgs.writeShellApplication {
      name = "claude-nix-format";
      runtimeInputs = [pkgs.jq pkgs.alejandra];
      text = ''
        file=$(jq -r '.tool_input.file_path // empty')
        [[ $file == *.nix && -f $file ]] || exit 0
        alejandra --quiet "$file" || true
      '';
    };

    # same for .gd, with GDQuest's formatter
    gdscript-format = pkgs.writeShellApplication {
      name = "claude-gdscript-format";
      runtimeInputs = [pkgs.jq pkgs.gdscript-formatter];
      text = ''
        file=$(jq -r '.tool_input.file_path // empty')
        [[ $file == *.gd && -f $file ]] || exit 0
        gdscript-formatter "$file" || true
      '';
    };

    # outside a project devenv would put .devenv in whatever dir claude started in
    # $1 is the project dir, plugin servers don't start there
    devenv-mcp = pkgs.writeShellApplication {
      name = "devenv-mcp";
      runtimeInputs = [pkgs.devenv];
      text = ''
        dir=''${1:-$PWD}
        while [[ $dir != / && ! -e $dir/devenv.nix ]]; do
          dir=$(dirname "$dir")
        done
        if [[ ! -e $dir/devenv.nix ]]; then
          dir=''${XDG_CACHE_HOME:-$HOME/.cache}/devenv-mcp
          mkdir -p "$dir"
          [[ -e $dir/devenv.nix ]] || echo '{}' >"$dir/devenv.nix"
        fi
        cd "$dir"
        exec devenv mcp
      '';
    };

    # sops token as a bearer; home assistant's mcp server takes long-lived tokens
    ha-headers = pkgs.writeShellApplication {
      name = "claude-ha-headers";
      runtimeInputs = [pkgs.jq];
      text = ''
        jq -n --rawfile token /run/secrets/home-assistant-token \
          '{Authorization: "Bearer \($token | rtrimstr("\n"))"}'
      '';
    };

    powerline-theme = pkgs.writeText "claude-powerline.json" (builtins.toJSON {
      theme = "custom";
      colors.custom = {
        directory = {
          bg = mauve;
          fg = base;
        };
        git = {
          bg = surface0;
          fg = green;
        };
        model = {
          bg = mantle;
          fg = lavender;
        };
        session = {
          bg = surface0;
          fg = teal;
        };
        block = {
          bg = surface1;
          fg = blue;
        };
        today = {
          bg = mantle;
          fg = teal;
        };
        month = {
          bg = surface0;
          fg = yellow;
        };
        tmux = {
          bg = mantle;
          fg = green;
        };
        context = {
          bg = surface1;
          fg = text;
        };
        contextWarning = {
          bg = peach;
          fg = base;
        };
        contextCritical = {
          bg = red;
          fg = base;
        };
        metrics = {
          bg = surface2;
          fg = text;
        };
        version = {
          bg = surface0;
          fg = mauve;
        };
        env = {
          bg = mantle;
          fg = flamingo;
        };
        weekly = {
          bg = surface0;
          fg = blue;
        };
        agent = {
          bg = surface1;
          fg = mauve;
        };
        thinking = {
          bg = surface0;
          fg = mauve;
        };
        cacheTimer = {
          bg = mantle;
          fg = green;
        };
        outputStyle = {
          bg = surface0;
          fg = teal;
        };
      };
    });

    # LSP and MCP servers from the store, not PATH
    # one server per extension, so .nix gets nil
    plugin = {
      name = "nix";
      description = "Language and MCP servers pinned by the NixOS config";

      mcpServers = {
        nixos = {
          type = "stdio";
          command = lib.getExe pkgs.mcp-nixos;
        };
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
        godot = {
          type = "stdio";
          command = lib.getExe self'.packages.godot-mcp;
        };
        devenv = {
          type = "stdio";
          command = lib.getExe devenv-mcp;
          args = ["\${CLAUDE_PROJECT_DIR}"];
        };
        home-assistant = {
          type = "http";
          url = "https://home.nouritsu.com/api/mcp";
          headersHelper = lib.getExe ha-headers;
        };
      };

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
        # with no editor open the bridge starts a headless one (slow first import)
        godot = {
          command = lib.getExe self'.packages.godot-lsp;
          extensionToLanguage.".gd" = "gdscript";
          startupTimeout = 300000;
        };
        basedpyright = {
          command = lib.getExe' pkgs.basedpyright "basedpyright-langserver";
          args = ["--stdio"];
          extensionToLanguage = {
            ".py" = "python";
            ".pyi" = "python";
          };
        };
        typescript = {
          command = lib.getExe pkgs.typescript-language-server;
          args = ["--stdio"];
          extensionToLanguage = {
            ".ts" = "typescript";
            ".mts" = "typescript";
            ".cts" = "typescript";
            ".tsx" = "typescriptreact";
            ".js" = "javascript";
            ".mjs" = "javascript";
            ".cjs" = "javascript";
            ".jsx" = "javascriptreact";
          };
        };
        svelte = {
          command = lib.getExe pkgs.svelte-language-server;
          args = ["--stdio"];
          extensionToLanguage.".svelte" = "svelte";
        };
        lua = {
          command = lib.getExe pkgs.lua-language-server;
          extensionToLanguage.".lua" = "lua";
        };
        qmlls = {
          command = lib.getExe' pkgs.kdePackages.qtdeclarative "qmlls";
          extensionToLanguage.".qml" = "qml";
        };
      };
    };
  in {
    # a directory marketplace so managed settings can enable the plugin in every
    # claude, the desktop app's included; version changes with the contents
    packages.claude-marketplace = let
      marketplace = pkgs.writeText "marketplace.json" (builtins.toJSON {
        name = "nixos-config";
        owner.name = "nouritsu";
        plugins = [
          {
            inherit (plugin) name description;
            source = "./plugins/${plugin.name}";
          }
        ];
      });
      manifest = pkgs.writeText "plugin.json" (builtins.toJSON (plugin
        // {
          version = builtins.substring 0 12 (builtins.hashString "sha256" (builtins.toJSON plugin));
        }));
    in
      pkgs.runCommand "claude-marketplace" {} ''
        install -Dm644 ${marketplace} $out/.claude-plugin/marketplace.json
        install -Dm644 ${manifest} $out/plugins/${plugin.name}/.claude-plugin/plugin.json
      '';

    # --settings outranks ~/.claude/settings.json; model, effort, tui and
    # plugins stay out so /model, /effort and /config still stick
    packages.claude-code = wrappers.wrappers.claude-code.wrap [
      {
        inherit pkgs;
        package = pkgs.claude-code;
      }
      {
        # remote control rejects the wrapper's flags and needs nonessential traffic
        runShell = [
          ''
            case ''${1-} in
              remote-control | rc)
                unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
                exec -a "$0" ${lib.getExe pkgs.claude-code} "$@"
                ;;
            esac
          ''
        ];

        settings = {
          attribution = {
            commit = "";
            pr = "";
          };

          statusLine = {
            type = "command";
            command = "${lib.getExe pkgs.claude-powerline} --config=${powerline-theme} --style=powerline";
          };

          # read-only, so safe in every project; merges with project allows
          # home assistant stays out, its tools switch real devices
          permissions.allow = [
            "Bash(nix eval *)"
            "Bash(nix flake show *)"
            "Bash(nix flake metadata *)"
            "Bash(journalctl *)"
            "Bash(gdscript-formatter lint *)"
            "Bash(gdscript-formatter --check *)"
            "mcp__plugin_nix_nixos"
            "mcp__plugin_nix_context7"
            "mcp__plugin_nix_godot__get_godot_version"
            "mcp__plugin_nix_godot__list_projects"
            "mcp__plugin_nix_godot__get_project_info"
            "mcp__plugin_nix_godot__get_debug_output"
            "mcp__plugin_nix_devenv__search_packages"
            "mcp__plugin_nix_devenv__search_options"
            "mcp__plugin_nix_devenv__list_processes"
            "mcp__plugin_nix_devenv__get_process_status"
            "mcp__plugin_nix_devenv__get_process_logs"
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
                  {
                    type = "command";
                    command = lib.getExe gdscript-format;
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
