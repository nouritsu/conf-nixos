{pkgs, ...}: let
  woomer = "${pkgs.woomer}/bin/woomer";
in {
  home.packages = [
    pkgs.woomer
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, Z, exec, ${woomer}"
  ];
}
