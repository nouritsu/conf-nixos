{
  den.aspects.niri-autoselect-portal.nixos = {
    self',
    lib,
    ...
  }: let
    portal = self'.packages.niri-autoselect-portal;
  in {
    services.dbus.packages = [portal];

    # shares start on the dynamic target, pointed with the Cast group
    xdg.portal = {
      extraPortals = [portal];
      config.niri."org.freedesktop.impl.portal.ScreenCast" = ["niri-autoselect" "gnome"];
    };

    systemd.user.services.niri-autoselect-portal = {
      description = "niri auto-select screencast portal";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session-pre.target"];
      before = ["xdg-desktop-portal.service"];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.niri-autoselect";
        ExecStart = lib.getExe portal;
        Restart = "on-failure";
      };
    };

    which-key'.menu.C.submenu = {
      w = {
        desc = "Window";
        icon = "f05af";
        cmd = "niri msg action set-dynamic-cast-window";
      };
      m = {
        desc = "Monitor";
        icon = "f0379";
        cmd = "niri msg action set-dynamic-cast-monitor";
      };
      x = {
        desc = "Clear";
        icon = "f015a";
        cmd = "niri msg action clear-dynamic-cast-target";
      };
    };
  };
}
