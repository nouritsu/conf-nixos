{waybar_lib, ...}: let
in {
  programs.waybar.settings.default."memory" = {
    interval = 15;
    format = "   {percentage}%";

    tooltip = true;
    tooltip-format = ''
      Memory: {used:0.2f} of {total} ({percentage}%), Available: {avail}
      Swap: {swapUsed:0.2f} of {swapTotal} ({swapPercentage}%), Available: {swapAvail}'';

    max-length = 10;
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "mem-fg: @surface0"
      "mem-bg: @peach"
    ];

    parts =
      /*
      css
      */
      ''
        #memory {
          color: @mem-fg;
          background-color: @mem-bg;
          padding-left: 6px;
          padding-right: 10px;
        }
      '';
  };
}
