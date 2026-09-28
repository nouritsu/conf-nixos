{
  # DMS owns the colours of the focus ring, borders and alt-tab highlight, and
  # the cursor theme and size. It writes them as KDL under ~/.config/niri/dms/,
  # which a config built into the store can only reach through an include.
  # Includes come after everything else here, so their properties win one by
  # one without touching widths, gaps or anything DMS does not write.
  #
  # Raw lines rather than extraSettings: toKdl quotes the node name, and DMS's
  # own include check (`dms config resolve-include`, behind the "First Time
  # Setup" banners in its settings) only matches a bare `include`. optional=true
  # keeps `niri validate` passing in the build sandbox, where neither file
  # exists.
  flake.nixosModules.wniri-dms = {...}: {
    settings.extraConfig = ''
      include optional=true "~/.config/niri/dms/colors.kdl"
      include optional=true "~/.config/niri/dms/cursor.kdl"
    '';
  };
}
