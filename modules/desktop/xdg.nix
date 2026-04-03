{self, ...}: {
  flake.nixosModules.desktop-xdg = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
    niri = self.packages.${system}.niri;
  in {
    environment.systemPackages = [
      pkgs.xwayland-satellite
    ];

    xdg.portal = {
      enable = true;
      configPackages = [niri];

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];

      config = {
        common = {
          default = ["gtk"];
        };

        niri = {
          default = ["gnome" "gtk"];
        };
      };
    };
  };
}
