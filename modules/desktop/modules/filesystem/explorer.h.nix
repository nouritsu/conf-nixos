{
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  wezterm-pkg = inputs.wezterm.packages.${osConfig.my.system.arch}.default;
  wezterm = rec {
    bin = "${wezterm-pkg}/bin/wezterm-gui";
    cwd = "${bin} start --cwd \$(${hyprcwd}|| echo \$HOME)";
  };

  yazi-pkg = inputs.yazi.packages.${osConfig.my.system.arch}.default;
  yazi = "${yazi-pkg}/bin/yazi";

  nautilus = rec {
    bin = "${pkgs.nautilus}/bin/nautilus";
    cwd = "${bin} \$(${hyprcwd} || echo \$HOME)";
  };
  hyprcwd = "${inputs.hyprcwd-rs.packages.${osConfig.my.system.arch}.default}/bin/hyprcwd";
in {
  home.packages = [
    pkgs.nautilus
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, E, exec, ${wezterm.cwd} -- ${yazi}"
    "SUPERSHIFT, E, exec, ${nautilus.cwd}"
  ];
}
