{
  lib,
  gui,
  supported_languages,
  ...
}: {
  imports = [./tui.nix ./defaults.nix] ++ lib.optionals gui [./gui.nix] ++ map (language: ./languages/${language}.nix) supported_languages;
}
