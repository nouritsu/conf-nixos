{
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
  wezterm = "${wezterm-pkg}/bin/wezterm";

  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  pastel = "${pkgs.pastel}/bin/pastel";

  colour-picker = pkgs.writeShellScriptBin "colour-picker" ''
    colour=$(${hyprpicker} --autocopy --lowercase-hex)
    if [ -n "$colour" ]; then
      ${wezterm} start --class colour-info -- sh -c "printf '\033[?25l'; echo ''${colour#\#} | ${pastel} color; read -s -r"
    fi
  '';
in {
  home.packages = [
    colour-picker
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPERALT, C, exec, ${colour-picker}/bin/colour-picker"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class colour\-info";
  in [
    "float on, ${match_}"
    "center on, ${match_}"
    "size (monitor_w/4.5) (monitor_h/5), ${match_}"
  ];

  wayland.windowManager.hyprland.settings.layerrule = [
    "no_anim on, match:namespace hyprpicker"
  ];
}
