{
  lib,
  vm,
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
    ++ lib.optionals (!vm) [./dconf.nix ./kitty.nix];
}
