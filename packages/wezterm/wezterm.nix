{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
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

            return config
          '';
      }
    ];
  };
}
