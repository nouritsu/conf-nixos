{
  den.aspects.dms.provides.theming.nixos = {
    pkgs,
    inputs',
    ...
  }: let
    qtengine = inputs'.qtengine.packages.default;
  in {
    # puts qt plugins on QT_PLUGIN_PATH, or no app finds qtengine
    qt.enable = true;

    # qt.platformTheme has no qtengine option, and the dms service
    # only syncs qtengine's config when it sees this variable
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qtengine";

    environment.systemPackages = [
      qtengine
      qtengine.qt5

      # DMS's "Apply GTK colors" copies and patches this
      pkgs.adw-gtk3
    ];

    # GTK 3 reads the cursor from dconf, which DMS never writes;
    # copy DMS's cursor.kdl choice there
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
