{
  lib,
  gui,
  ...
}: {
  imports =
    [
      ./helix.nix
      ./git.nix
      ./prompt.nix
      ./shell.nix
      ./zoxide.nix
      ./tealdeer.nix
    ]
    ++ lib.optionals gui [./kitty.nix ./foot.nix ./hyprland.nix ./tofi.nix];
}
