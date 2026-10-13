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
    ];
  };
}
