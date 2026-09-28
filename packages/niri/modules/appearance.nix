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

        # Its colours come from DMS, through ./dms.nix.
        focus-ring.width = 3;
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
