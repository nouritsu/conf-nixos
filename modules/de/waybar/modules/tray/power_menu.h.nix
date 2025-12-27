{
  pkgs,
  waybar_lib,
  ...
}: let
  wleave = "${pkgs.wleave}/bin/wleave";
in {
  programs.waybar.settings.default."custom/power-menu" = {
    format = "󰤄 ";
    on-click = "${wleave} --no-version-info";
    tooltip-format = "Power Menu";
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "power-menu-fg: @crust"
      "power-menu-bg: @red"
    ];

    parts =
      /*
      css
      */
      ''
        #custom-power-menu {
          font-size: 18px;
          color: @power-menu-fg;
          background-color: @power-menu-bg;
        }
      '';
  };
}
