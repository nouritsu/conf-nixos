{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
  yazi-pkg = inputs.yazi.packages.${osConfig.my.system.arch}.default;
  hyprcwd-pkg = inputs.hyprcwd-rs.packages.${osConfig.my.system.arch}.default;

  hyprcwd = lib.getExe' hyprcwd-pkg "hyprcwd";
  yazi = lib.getExe yazi-pkg;
  wezterm = rec {
    bin = lib.getExe' wezterm-pkg "wezterm-gui";
    cwd = "${bin} start --cwd \$(${hyprcwd}|| echo \$HOME)";
  };
  nautilus = rec {
    bin = lib.getExe pkgs.nautilus;
    cwd = "${bin} \$(${hyprcwd} || echo \$HOME)";
  };
in {
  home.packages = [
    pkgs.nautilus
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, E, exec, ${wezterm.cwd} -- ${yazi}"
    "SUPERSHIFT, E, exec, ${nautilus.cwd}"
  ];
}
