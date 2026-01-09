{waybar_lib, ...}: {
  imports = [
    ./cpu.h.nix
    ./gpu.h.nix
    ./memory.h.nix
    ./disk.h.nix
  ];

  programs.waybar.settings.default = {
    "group/gstatline" = {
      orientation = "inherit";
      modules = [
        "custom/divl#6"
        "disk"
        "custom/divl#5"

        "memory"
        "custom/divl#4"

        "custom/gpu"
        "custom/divl#3"

        "cpu"
        "temperature"
        "custom/divli#0"
      ];
    };

    # dividers (right -> left)
    "custom/divli#0" = waybar_lib.div.li;
    "custom/divl#3" = waybar_lib.div.l;
    "custom/divl#4" = waybar_lib.div.l;
    "custom/divl#5" = waybar_lib.div.l;
    "custom/divl#6" = waybar_lib.div.l;
  };

  my.waybar.styles = {
    parts =
      /*
      css
      */
      ''
        #gstatline #custom-divli.0 {
          background-color: @crust;
          color: @lavender;
        }

        #gstatline #custom-divl.3 {
          color: @lavender;
          background-color: @green;
        }

        #gstatline #custom-divl.4 {
          color: @green;
          background-color: @peach;
        }

        #gstatline #custom-divl.5 {
          color: @peach;
          background-color: @maroon;
        }

        #gstatline #custom-divl.6 {
          color: @maroon;
          background-color: @crust;
        }
      '';
  };
}
