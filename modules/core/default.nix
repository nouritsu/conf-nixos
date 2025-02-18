{
  lib,
  gui,
  vm,
  ...
}: {
  imports =
    [./tui.nix ./stylix.nix ./defaults.nix ./development.nix]
    ++ lib.optionals gui [./gui.nix]
    ++ lib.optionals (!vm) [./services.nix ./bootloader.nix ./networking.nix ./locale.nix ./dm.nix];
}
