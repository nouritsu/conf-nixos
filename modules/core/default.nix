{
  lib,
  gui,
  wsl,
  ...
}: {
  imports =
    [./tui.nix ./defaults.nix ./development.nix]
    ++ lib.optionals gui [./gui.nix ./stylix ./dm.nix]
    ++ lib.optionals (!wsl) [./services.nix ./bootloader.nix ./networking.nix ./locale.nix];
}
