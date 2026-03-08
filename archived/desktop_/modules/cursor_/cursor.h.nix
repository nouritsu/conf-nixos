{
  pkgs,
  lib,
  ...
}: {
  home.pointerCursor = lib.mkForce {
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };
}
