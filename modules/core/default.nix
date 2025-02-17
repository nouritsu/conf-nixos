{
  lib,
  gui,
  ...
}: {
  imports = [./tui.nix ./stylix.nix ./defaults.nix] ++ lib.optionals gui [./gui.nix];
}
