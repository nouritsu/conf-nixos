{
  flake.nixosModules.wniri-rules = {
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
    ];

    settings.layer-rules = [
      {
        matches = [{namespace = "^wlr_which_key$";}];
        shadow.on = _: {};
        geometry-corner-radius = 12;
      }
    ];
  };
}
