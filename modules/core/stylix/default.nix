{...}: {
  imports = [
    ./wallpapers
    ./fonts.nix
    ./colors.nix
    ./cursor.nix
  ];

  stylix.enable = true;
  stylix.enableReleaseChecks = false;
}
