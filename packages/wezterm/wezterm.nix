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

              -- keybinds, defaults off
              disable_default_key_bindings = true,
              keys = {
                { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
                { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
                { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
                { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
                { key = "f", mods = "CTRL", action = act.Search "CurrentSelectionOrEmptyString" },
                { key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect },
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
