{
  lib,
  gui,
  ...
}: {
  imports =
    [./tui ./stylix.nix]
    ++ lib.optionals gui [./gui];
}
