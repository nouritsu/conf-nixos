{
  flake.nixosModules.app-steam = {pkgs, ...}: {
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

    environment.variables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
