{
  lib,
  gui,
  vm,
  ...
}: {
  imports =
    [./tui.nix ./defaults.nix ./development.nix]
    ++ lib.optionals gui [./gui.nix ./stylix.nix ./dm.nix]
    ++ lib.optionals (!vm) [./services.nix ./bootloader.nix ./networking.nix ./locale.nix];
}
