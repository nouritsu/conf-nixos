{
  lib,
  gui,
  ...
}: {
  imports =
    [./tui ./stylix.nix ./keyboard.nix]
    ++ lib.optionals gui [./gui];
}
