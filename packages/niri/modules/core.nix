{
  flake.nixosModules.wniri-core = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      layout = {
        empty-workspace-above-first = _: {};
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 0.5;}
          {proportion = 2.0 / 3.0;}
        ];
      };
    };
  };
}
