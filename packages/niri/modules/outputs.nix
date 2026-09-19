{
  flake.nixosModules.wniri-outputs = {...}: {
    # The wrapper is built per-system rather than per-host, so both hosts share
    # this block. niri ignores outputs whose connector is not present, so each
    # display only takes effect on the machine it is attached to.
    settings.outputs = {
      # pc: desktop monitor.
      "DP-1" = {
        mode = "2560x1440@164.999";
        variable-refresh-rate = _: {
          props = {
            on-demand = true;
          };
        };
      };

      # lenovo: built-in panel.
      "eDP-1" = {
        mode = "1920x1200@59.999";
      };
    };
  };
}
