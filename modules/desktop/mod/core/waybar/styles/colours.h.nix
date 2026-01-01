{
  lib,
  waybar_lib,
  ...
}: {
  my.waybar.styles.define_parts = lib.mkBefore (
    lib.concatStringsSep "\n" (lib.mapAttrsToList waybar_lib.mk_define waybar_lib.palette)
    + "\n"
    + waybar_lib.mk_batch_defines [
      # fg: foreground, bg: background, br: border
      "accent: @mauve"

      "main-fg: @text"
      "main-bg: @crust"
      "main-br: @subtext0"

      "hover-fg: alpha(@main-fg, 0.75)"
      "hover-bg: @base"

      "outline: shade(@main-bg, 0.5)"
    ]
  );
}
