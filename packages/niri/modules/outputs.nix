{
  flake.nixosModules.wniri-outputs = {...}: {
    settings.outputs = {
      "DP-1" = {
        mode = "2560x1440@164.999";
        variable-refresh-rate = _: {
          props = {
            on-demand = true;
          };
        };
      };
    };
  };
}
