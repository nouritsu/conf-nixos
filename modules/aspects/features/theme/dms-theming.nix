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
  };
}
