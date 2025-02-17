{
  lib,
  gui,
  ...
}: {
  imports = [./tui.nix ./stylix.nix ./defaults.nix ./development.nix] ++ lib.optionals gui [./gui.nix];
}
