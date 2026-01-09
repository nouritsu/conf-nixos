{waybar_lib, ...}: {
  programs.waybar.settings.default = {
    disk = {
      interval = 30;
      format = "   {used}/{total}";
    };
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "disk-fg: @surface0"
      "disk-bg: @maroon"
    ];

    parts =
      /*
      css
      */
      ''
        #disk {
          color: @disk-fg;
          background-color: @disk-bg;
          padding-left: 6px;
          padding-right: 10px;
        }
      '';
  };
}
