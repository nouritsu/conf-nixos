{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  xdg.portal.config.common.default = ["hyprland" "gtk"];

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';
}
