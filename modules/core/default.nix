{
  gui,
  lib,
  ...
}: {
  imports =
    [
      ./tui/default.nix
    ]
    ++ lib.optionals gui [
      ./gui/default.nix
    ];
}
