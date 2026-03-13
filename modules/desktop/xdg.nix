{
  flake.nixosModules.desktop-xdg = {...}: {
    my.hmModules = ["desktop-xdg"];
  };

  flake.homeModules.desktop-xdg = {pkgs, ...}: {
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = ["hyprland" "gtk"];
    };

    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';
  };
}
