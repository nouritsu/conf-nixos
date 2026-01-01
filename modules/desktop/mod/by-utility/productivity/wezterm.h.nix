{
  inputs,
  osConfig,
  ...
}: let
  wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
  wezterm = rec {
    bin = "${wezterm-pkg}/bin/wezterm-gui";
    cwd = "${bin} start --cwd \$(${hyprcwd}|| echo \$HOME)";
  };
  wezterm-mux-server = "${wezterm-pkg}/bin/wezterm-mux-server";

  hyprcwd = "${inputs.hyprcwd-rs.packages.${osConfig.my.system.arch}.default}/bin/hyprcwd";
in {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    package = wezterm-pkg;
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
          skip_close_confirmation_for_processes_named =  {
            'bash',
            'sh',
            'fish',
            'yazi',
          },
        }
      '';
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "${wezterm-mux-server} --daemonize"
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, T, exec, ${wezterm.bin}"
    "SUPER, RETURN, exec, ${wezterm.cwd}"
  ];
}
