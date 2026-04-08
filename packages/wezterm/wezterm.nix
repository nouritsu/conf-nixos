{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {pkgs, ...}: {
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

            return {
              -- appearance
              color_scheme = "Catppuccin Mocha",
              font = wezterm.font "ZedMono Nerd Font",
              font_size = 14.0,

              hide_tab_bar_if_only_one_tab = true,
              show_tab_index_in_tab_bar = false,
              show_new_tab_button_in_tab_bar = false,
              show_close_tab_button_in_tabs = false,
              switch_to_last_active_tab_when_closing_tab = true,
              skip_close_confirmation_for_processes_named = {
                'bash',
                'sh',
                'fish',
                'yazi',
              },
            }
          '';
      }
    ];
  };
}
