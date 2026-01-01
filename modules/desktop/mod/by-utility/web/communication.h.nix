{pkgs, ...}: let
  vesktop = "${pkgs.vesktop}/bin/vesktop";
in {
  home.packages = [
    pkgs.telegram-desktop
    pkgs.whatsapp-electron
  ];

  programs.vesktop.enable = true;

  wayland.windowManager.hyprland.settings.exec-once = [
    "sleep 5 && ${vesktop} --start-minimized" # delay so it appears on tray
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, D, exec, ${vesktop}"
  ];
}
