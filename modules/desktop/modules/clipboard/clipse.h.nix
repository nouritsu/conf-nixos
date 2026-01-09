{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
  wezterm = lib.getExe' wezterm-pkg "wezterm";
  clipse = lib.getExe pkgs.clipse;

  clipboard-history = pkgs.writeShellScriptBin "clipboard-history" ''
    ${wezterm} start --class clipboard-history ${clipse}
  '';
in {
  services.clipse = {
    enable = true;
    historySize = 256;
  };

  home.packages = [
    pkgs.wl-clipboard
    pkgs.clipse
    clipboard-history
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, C, exec, ${clipboard-history}/bin/clipboard-history"
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "clipse -listen"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class clipboard\-history";
  in [
    "float on, ${match_}"
    "center on, ${match_}"
    "size (monitor_w/3) (monitor_h/3), ${match_}"
  ];
}
