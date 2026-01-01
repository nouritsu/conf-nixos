{
  inputs,
  pkgs,
  ...
}: let
  walker = "${pkgs.walker}/bin/walker";
in {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, SUPER_L, exec, ${walker}"
  ];
}
