{self, ...}: {
  flake.nixosModules.desktop-xdg = {...}: {
    my.hmModules = ["desktop-xdg"];
  };

  flake.homeModules.desktop-xdg = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];

      configPackages = [self.packages.${system}.niri];
    };
  };
}
