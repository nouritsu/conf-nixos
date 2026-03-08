{
  flake.nixosModules.app-web = {pkgs, ...}: {
    my.hmModules = ["app-web"];

    environment.systemPackages = [
      pkgs.telegram-desktop
      pkgs.whatsapp-electron
    ];
  };

  flake.homeModules.app-web = {...}: {
    programs.vesktop.enable = true;

    wayland.windowManager.hyprland.settings.exec-once = [
      "sleep 5 && vesktop --start-minimized" # delayed so it appears on tray
    ];

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, D, exec, vesktop"
    ];
  };
}
