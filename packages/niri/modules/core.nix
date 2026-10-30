{
  flake.nixosModules.wniri-core = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      hotkey-overlay.skip-at-startup = _: {};

      # mouse/touchpad come from Dux; a block here would be replaced anyway

      # drag to an edge: left/right scrolls (default 1500), top/bottom switches workspaces
      gestures.dnd-edge-view-scroll.max-speed = 3000;

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
