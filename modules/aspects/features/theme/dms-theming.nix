{
  # DMS decides the desktop's colours and icon theme: its matugen templates
  # write GTK and KDE colour schemes from whichever theme is picked in its
  # settings. This provide installs what those files are read through.
  den.aspects.dms.provides.theming.nixos = {
    pkgs,
    inputs',
    ...
  }: let
    qtengine = inputs'.qtengine.packages.default;
  in {
    # Puts the system profile's lib/qt-*/plugins on QT_PLUGIN_PATH; without it
    # no app finds qtengine. stylix used to set this as a side effect.
    qt.enable = true;

    # qt.platformTheme is an enum without qtengine. As a session variable it
    # also reaches the dms service, which only syncs qtengine's config when it
    # sees this.
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qtengine";

    environment.systemPackages = [
      qtengine
      qtengine.qt5

      # DMS's "Apply GTK colors" copies adw-gtk3 from XDG_DATA_DIRS into
      # ~/.local/share/themes and patches its colours into that copy.
      pkgs.adw-gtk3
    ];

    # DMS applies the cursor through niri: it writes cursor.kdl, niri draws
    # its own cursor from it and exports XCURSOR_* to everything it spawns,
    # and GTK 4, Qt 6 and Chromium ask niri for the cursor anyway
    # (cursor-shape-v1). GTK 3 draws its own from dconf's cursor-theme, which
    # DMS never writes, so this copies DMS's choice there whenever the file
    # changes. It also keeps the `default` theme pointing at it for anything
    # started without XCURSOR_THEME.
    systemd.user.paths.dms-cursor-sync = {
      wantedBy = ["graphical-session.target"];
      pathConfig.PathChanged = "%h/.config/niri/dms/cursor.kdl";
    };

    systemd.user.services.dms-cursor-sync = {
      description = "Copy the DMS cursor into dconf for GTK 3";
      wantedBy = ["graphical-session.target"];
      serviceConfig.Type = "oneshot";
      path = [pkgs.dconf pkgs.gnused pkgs.coreutils];
      script = ''
        kdl=$HOME/.config/niri/dms/cursor.kdl
        key=/org/gnome/desktop/interface
        theme=$(sed -n 's/^[[:space:]]*xcursor-theme "\(.*\)"$/\1/p' "$kdl" 2>/dev/null)
        size=$(sed -n 's/^[[:space:]]*xcursor-size \([0-9]*\)$/\1/p' "$kdl" 2>/dev/null)

        if [ -n "$theme" ]; then
          dconf write "$key/cursor-theme" "'$theme'"
          mkdir -p "$HOME/.icons/default"
          printf '[Icon Theme]\nInherits=%s\n' "$theme" > "$HOME/.icons/default/index.theme"
        else
          dconf reset "$key/cursor-theme"
        fi

        if [ -n "$size" ]; then
          dconf write "$key/cursor-size" "$size"
        else
          dconf reset "$key/cursor-size"
        fi
      '';
    };
  };
}
