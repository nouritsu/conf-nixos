{
  pkgs,
  inputs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    package = inputs.wezterm.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraConfig =
      /*
      lua
      */
      ''
        return {
          hide_tab_bar_if_only_one_tab = true,
          show_tab_index_in_tab_bar = false,
          show_new_tab_button_in_tab_bar = false,
          show_close_tab_button_in_tabs = false,
          switch_to_last_active_tab_when_closing_tab = true,
        }
      '';
  };
}
