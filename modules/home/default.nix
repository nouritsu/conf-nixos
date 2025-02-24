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
      ./hyprland.nix
    ]
    ++ lib.optionals (!gui) [./kitty.nix];
}
