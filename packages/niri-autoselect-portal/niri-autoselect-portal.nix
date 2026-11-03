{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    # screencast backend that always picks niri's dynamic cast target, no dialog
    packages.niri-autoselect-portal = pkgs.buildGoModule {
      pname = "niri-autoselect-portal";
      version = "0.1.0-${inputs.niri-autoselect-portal.shortRev}";
      src = inputs.niri-autoselect-portal;
      vendorHash = null;
      env.CGO_ENABLED = 0;

      postInstall = ''
        mkdir -p $out/share/xdg-desktop-portal/portals $out/share/dbus-1/services

        cat > $out/share/xdg-desktop-portal/portals/niri-autoselect.portal <<EOF
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.niri-autoselect
        Interfaces=org.freedesktop.impl.portal.ScreenCast
        EOF

        cat > $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.niri-autoselect.service <<EOF
        [D-BUS Service]
        Name=org.freedesktop.impl.portal.desktop.niri-autoselect
        Exec=$out/bin/niri-autoselect-portal
        SystemdService=niri-autoselect-portal.service
        EOF
      '';

      meta.mainProgram = "niri-autoselect-portal";
    };
  };
}
