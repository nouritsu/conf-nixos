{
  flake.nixosModules.wniri-rules = let
    # proton, gamescope, eden, minecraft
    games = [
      {app-id = "^steam_app_\\d+$";}
      {app-id = "^gamescope$";}
      {app-id = "eden_emu|^eden$";}
      {app-id = "^Minecraft";}
    ];
  in {
    # pc's main monitor; elsewhere the first output
    settings.workspaces.games.open-on-output = "DP-3";

    settings.window-rules = [
      # big picture never asks for fullscreen through xwayland-satellite
      {
        matches = [
          {
            app-id = "^steam$";
            title = "^Steam Big Picture Mode$";
          }
        ];
        open-fullscreen = true;
      }

      # undertale: fullscreen letterboxes 640x480 at an exact 3x; a maximised column scales it unevenly
      {
        matches = [
          {app-id = "^steam_app_391540$";}
          {title = "^UNDERTALE$";}
        ];
        open-fullscreen = true;
      }

      {
        matches = games;
        open-on-workspace = "games";
        open-focused = true;
      }
    ];

    settings.layer-rules = [
      {
        matches = [{namespace = "^wlr_which_key$";}];
        shadow.on = _: {};
        geometry-corner-radius = 12;
      }

      # live halves capture the screen under shatterlock, not shatterlock itself
      {
        matches = [{namespace = "^shatterlock$";}];
        hide-from-own-capture = true;
      }
    ];
  };
}
