{waybar_lib, ...}: {
  imports = [
    ./power_menu.h.nix
    ./tray.h.nix
    ./clock.h.nix
  ];

  programs.waybar.settings.default = {
    "group/gtray" = {
      orientation = "inherit";
      modules = [
        "custom/divl#2"
        "tray"

        "custom/divl#1"
        "custom/clock"

        "custom/divl#0"
        "custom/power-menu"
      ];
    };

    # dividers (right -> left)
    "custom/divl#0" = waybar_lib.div.l;
    "custom/divl#1" = waybar_lib.div.l;
    "custom/divl#2" = waybar_lib.div.l;
  };

  my.waybar.styles.parts =
    /*
    css
    */
    ''
      #gtray #custom-divl.0 {
        color: @red;
        background-color: @mantle;
      }

      #gtray #custom-divl.1 {
        color: @mantle;
        background-color: @base;
      }

      #gtray #custom-divl.2 {
        color: @base;
      }
    '';
}
