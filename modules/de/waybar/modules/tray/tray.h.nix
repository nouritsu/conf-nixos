{waybar_lib, ...}: {
  programs.waybar.settings.default.tray = {
    spacing = 10;
    show-passive-items = true;
    reverse-direction = true;
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_define "tray-bg" "@base";

    parts =
      /*
      css
      */
      ''
        #tray {
          background-color: @tray-bg;
          padding-left: 8px;
          padding-right: 12px;
        }
      '';
  };
}
