{self, ...}: {
  flake.nixosModules.desktop-xdg = {...}: {
    my.hmModules = ["desktop-xdg"];
  };

  flake.homeModules.desktop-xdg = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
    niri = self.packages.${system}.niri;
  in {
    xdg.portal = {
      enable = true;
      configPackages = [niri];

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];

      config = {
        common = {
          default = ["gtk"];
        };

        niri = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.RemoteDesktop" = ["wlr"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.AppChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
          "org.freedesktop.impl.portal.Settings" = ["gtk"];
        };
      };
    };
  };
}
