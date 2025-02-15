{
  lib,
  gui,
  ...
}: {
  imports = [./tui.nix ./defaults.nix] ++ lib.optionals gui [./gui.nix];
}
