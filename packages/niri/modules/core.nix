{
  flake.nixosModules.wniri-core = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
    };
  };
}
