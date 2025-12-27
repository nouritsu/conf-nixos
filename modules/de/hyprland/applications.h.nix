{
  inputs,
  usrconf,
  pkgs,
  ...
}: let
  # Applications
  terminal = rec {
    bin = "${pkgs.wezterm}/bin/wezterm-gui";
    home = "${bin} $HOME";
    cwd = "${bin} start --cwd \$(${hyprcwd}|| echo \$HOME)";
  };
  menu = "${pkgs.walker}/bin/walker";
  browser = "${pkgs.firefox}/bin/firefox";
  explorer = "${terminal.cwd} -- yazi";
  vesktop = "${pkgs.vesktop}/bin/vesktop";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";

  # Helpers
  hyprcwd = "${inputs.hyprcwd-rs.packages.${usrconf.system}.default}/bin/hyprcwd";
in {
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, T, exec, ${terminal.home}"
    "SUPER, RETURN, exec, ${terminal.cwd}"
    "SUPER, W, exec, ${browser}"
    "SUPER, E, exec, ${explorer}"
    "SUPER, SUPER_L, exec, ${menu}"
    "SUPER, D, exec, ${vesktop}"
    "SUPER, C, exec, ${hyprpicker} --autocopy --lowercase-hex"
  ];
}
