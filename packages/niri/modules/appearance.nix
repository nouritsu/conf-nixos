{
  flake.nixosModules.wniri-appearance = {...}: {
    settings = {
      layout = {
        gaps = 5;
        struts = {
          left = 5;
          right = 5;
          top = 5;
          bottom = 5;
        };
        border = {
          width = 3;
          "active-color" = "#cba6f7";
          "inactive-color" = "#313244";
        };
        focus-ring.off = null;
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
