{
  # DMS's niri settings pages (layout, displays, input, keybinds, window
  # rules, cursor, theme colours) write KDL under ~/.config/niri/dms/, which a
  # config built into the store can only reach through includes. They come
  # last so DMS wins: plain sections merge property by property, binds replace
  # a key bound earlier, and window rules land after the ones here. Anything
  # DMS writes is therefore left out of the other modules, so each setting has
  # one owner. The order is DMS's own default config, plus the window-rule and
  # wallpaper-blur fragments its settings add.
  #
  # Raw lines rather than extraSettings: toKdl quotes the node name, and DMS's
  # own include check (`dms config resolve-include`, behind the "First Time
  # Setup" banners in its settings) only matches a bare `include`. optional=true
  # keeps `niri validate` passing in the build sandbox, where no file exists.
  flake.nixosModules.wniri-dms = {lib, ...}: {
    settings.extraConfig = lib.concatMapStrings (name: ''
      include optional=true "~/.config/niri/dms/${name}.kdl"
    '') ["colors" "layout" "alttab" "binds" "outputs" "cursor" "input" "windowrules" "wpblur"];
  };
}
