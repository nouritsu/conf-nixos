{
  lib,
  gui,
  ...
}: {
  imports =
    [./tui]
    ++ lib.optionals gui [./gui];
}
