{
  lib,
  gui,
  wsl,
  ...
}: {
  imports =
    [./tui]
    ++ lib.optionals gui [./gui ./stylix]
    ++ lib.optionals (!wsl) [./device];
}
