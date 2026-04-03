{
  flake.nixosModules.wniri-appearance = {...}: {
    settings = {
      prefer-no-csd = _: {};

      layout = {
        gaps = 5;
        struts = {
          left = 5;
          right = 5;
          top = 5;
          bottom = 5;
        };

        focus-ring = {
          width = 3;
          "active-color" = "#cba6f7"; # mauve
          "inactive-color" = "#313244"; # surface0
          "urgent-color" = "#f38ba8"; # red
        };
      };

      window-rules = [
        {
          geometry-corner-radius = 12.0;
          clip-to-geometry = true;
        }
      ];
    };
  };
}
