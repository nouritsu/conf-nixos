{
  flake.nixosModules.wniri-core = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      # Mouse and touchpad settings come from DMS (./dms.nix). Pointing-device
      # sections do not merge across includes, so a mouse block here would be
      # replaced wholesale anyway.

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
