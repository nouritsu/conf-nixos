{
  flake.nixosModules.wniri-core = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      hotkey-overlay.skip-at-startup = _: {};

      # mouse/touchpad come from DMS; a block here would be replaced anyway

      layout = {
        empty-workspace-above-first = _: {};
        default-column-width = {proportion = 0.5;};
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 0.5;}
          {proportion = 2.0 / 3.0;}
        ];
      };
    };
  };
}
