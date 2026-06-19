{
  flake.nixosModules.app-steam = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      extest.enable = true; # translate X11 input to uinput so Steam Input works on Wayland
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;

    environment.systemPackages = [
      pkgs.mangohud
      pkgs.protonup-ng
      pkgs.lumafly
      pkgs.r2modman
      pkgs.satisfactorymodmanager
      pkgs.eden
    ];

    environment.variables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
