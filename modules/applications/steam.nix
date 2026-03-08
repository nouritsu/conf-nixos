{
  flake.nixosModules.app-steam = {pkgs, ...}: {
    my.hmModules = ["app-steam"];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;

    environment.systemPackages = [
      pkgs.mangohud
      pkgs.protonup-ng
      pkgs.r2modman
      pkgs.satisfactorymodmanager
    ];
  };

  flake.homeModules.app-steam = {...}: {
    home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";

    wayland.windowManager.hyprland.settings.exec-once = [
      "steam -silent"
    ];
  };
}
