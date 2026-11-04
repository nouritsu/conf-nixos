{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    self',
    pkgs,
    inputs',
    ...
  }: {
    packages.wezterm = wrappers.wrappers.wezterm.wrap [
      {
        inherit pkgs;
        package = pkgs.wezterm;
      }
      {
        "wezterm.lua".content =
          /*
          lua
          */
          ''
            local wezterm = require "wezterm"
            local act = wezterm.action

            -- on the alt screen (tuios, helix) the key goes to the app
            local function alt_screen(key, mods, action)
              return {
                key = key,
                mods = mods,
                action = wezterm.action_callback(function(window, pane)
                  if pane:is_alt_screen_active() then
                    window:perform_action(act.SendKey { key = key, mods = mods }, pane)
                  else
                    window:perform_action(action, pane)
                  end
                end),
              }
            end

            local config = {
              font = wezterm.font "Maple Mono NF",
              font_size = 14.0,

              hide_tab_bar_if_only_one_tab = true,
              show_tab_index_in_tab_bar = false,
              show_new_tab_button_in_tab_bar = false,
              show_close_tab_button_in_tabs = false,
              switch_to_last_active_tab_when_closing_tab = true,

              -- never confirm close
              window_close_confirmation = "NeverPrompt",

              -- the default only escapes spaces
              quote_dropped_files = "Posix",

              -- tuios's ctrl+space leader and ctrl+alt chords
              enable_kitty_keyboard = true,

              -- keybinds, defaults off
              disable_default_key_bindings = true,
              keys = {
                { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
                { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
                alt_screen("PageUp", "SHIFT", act.ScrollByPage(-1)),
                alt_screen("PageDown", "SHIFT", act.ScrollByPage(1)),
                alt_screen("f", "CTRL", act.Search "CurrentSelectionOrEmptyString"),
                alt_screen("Space", "CTRL|SHIFT", act.QuickSelect),
                { key = "l", mods = "CTRL|SHIFT", action = act.ClearScrollback "ScrollbackOnly" },
              },
            }

            -- appearance
            dofile("${inputs'.catppuccin.packages.wezterm}/plugin/init.lua").apply_to_config(config, {
              flavor = "mocha",
              accent = "mauve",
            })

            -- each window's directory, and its full-screen program, under its niri id for wezterm-restore;
            -- a window's id is learnt when it takes focus
            local niri_session = (os.getenv("NIRI_SOCKET") or ""):match("([^/]+)%.sock$")
            local state_dir = (os.getenv("XDG_STATE_HOME") or wezterm.home_dir .. "/.local/state") .. "/wezterm/niri/" .. (niri_session or "")
            local last_save, made_dir = 0, false

            wezterm.on("window-focus-changed", function(window)
              if not niri_session or not window:is_focused() then
                return
              end
              local ok, out = wezterm.run_child_process { "niri", "msg", "--json", "focused-window" }
              local focused = ok and wezterm.json_parse(out)
              if type(focused) == "table" and focused.app_id == "org.wezfurlong.wezterm" and focused.pid == wezterm.procinfo.pid() then
                wezterm.GLOBAL["niri:" .. window:window_id()] = focused.id
              end
            end)

            wezterm.on("update-status", function()
              if not niri_session or os.time() - last_save < 10 then
                return
              end
              last_save = os.time()

              local windows = {}
              for _, gui in ipairs(wezterm.gui.gui_windows()) do
                local id = wezterm.GLOBAL["niri:" .. gui:window_id()]
                if id then
                  local pane = gui:active_pane()
                  local cwd = pane:get_current_working_dir()
                  local process = pane:is_alt_screen_active() and pane:get_foreground_process_info()
                  windows[tostring(id)] = { cwd = cwd and cwd.file_path, argv = process and process.argv }
                end
              end

              -- one file per process: tuios and btop windows are wezterms of their own
              local file = state_dir .. "/" .. wezterm.procinfo.pid() .. ".json"
              if next(windows) == nil then
                os.remove(file)
                return
              end
              if not made_dir then
                made_dir = wezterm.run_child_process { "mkdir", "-p", state_dir }
              end
              local tmp = io.open(file .. ".tmp", "w")
              if tmp then
                tmp:write(wezterm.json_encode(windows))
                tmp:close()
                os.rename(file .. ".tmp", file)
              end
            end)

            return config
          '';
      }
    ];

    # nirinit's launch command for wezterm: the saved window's directory and full-screen program
    packages.wezterm-restore = pkgs.writeShellApplication {
      name = "wezterm-restore";
      runtimeInputs = [self'.packages.wezterm pkgs.fish pkgs.jq pkgs.findutils pkgs.coreutils pkgs.gawk];
      # jq and fish see their own $vars
      excludeShellChecks = ["SC2016"];
      text = ''
        state=''${XDG_STATE_HOME:-$HOME/.local/state}/wezterm/niri
        current=$(basename "''${NIRI_SOCKET:-none}" .sock)

        # the session nirinit saved the window in, else the newest before this one; older ones go
        previous=''${NIRINIT_NIRI_SESSION:-}
        if [[ -z $previous || $previous == */* ]]; then
          previous=$(find "$state" -mindepth 1 -maxdepth 1 -type d ! -name "$current" -printf '%T@ %f\n' 2> /dev/null | sort -rn | awk 'NR == 1 { print $2 }') || previous=
        fi
        find "$state" -mindepth 1 -maxdepth 1 -type d ! -name "$current" ! -name "''${previous:-$current}" -exec rm -rf {} + 2> /dev/null || true

        entry=
        if [[ -n ''${NIRINIT_WINDOW_ID:-} && -n $previous ]]; then
          entry=$(jq -cs --arg id "$NIRINIT_WINDOW_ID" 'add | .[$id] // empty' "$state/$previous"/*.json < /dev/null 2> /dev/null) || entry=
        fi

        cwd=$(jq -r '.cwd // empty' <<< "$entry")
        [[ -d $cwd ]] || cwd=$HOME
        mapfile -d "" -t argv < <(jq --raw-output0 '.argv // [] | .[]' <<< "$entry")

        case ''${argv[0]:-} in
          "" | sudo | */sudo | doas | */doas | su | */su | run0 | */run0)
            exec wezterm start --cwd "$cwd"
            ;;
        esac

        # typed at the first prompt: it gets its own job, so wezterm saves it and not fish, and
        # quitting it leaves a shell in the same directory
        init=$(fish --no-config -c '
          string join " " -- (string escape -- $argv) | read -l cmd
          printf "function __wezterm_restore --on-event fish_prompt; functions -e __wezterm_restore; commandline -r -- %s; commandline -f execute; end" (string escape -- $cmd)
        ' "''${argv[@]}")
        exec wezterm start --cwd "$cwd" -- fish -l -C "$init"
      '';
    };
  };
}
