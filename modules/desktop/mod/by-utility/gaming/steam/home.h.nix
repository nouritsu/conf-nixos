{pkgs, ...}: let
  steam = "${pkgs.steam}/bin/steam";
in {
  home.packages = [
    pkgs.mangohud
    pkgs.protonup-ng
    pkgs.r2modman
    pkgs.satisfactorymodmanager
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "${steam} -silent"
  ];
}
