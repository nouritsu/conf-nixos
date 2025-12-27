{
  pkgs,
  usrconf,
  inputs,
  waybar_lib,
  ...
}: let
  hyprland = inputs.hyprland.packages.${usrconf.system}.hyprland;
  hyprctl = "${hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";

  divr-gws0 = pkgs.writeShellScript "waybar-divr-gws0" ''
    id=$(${hyprctl} monitors -j | ${jq} -r '.[] | select(.focused) | .specialWorkspace.id')
    class="inactive"

    if [[ -n "$id" ]] && [[ "$id" -lt 0 ]]; then
      class="active"
    fi

    echo "{\"class\": \"$class\"}"
  '';
in {
  imports = [
    ./scratchpad.h.nix
    ./workspaces.h.nix
  ];

  programs.waybar.settings.default = {
    "group/gworkspaces" = {
      orientation = "inherit";
      modules = [
        "custom/scratchpad"
        "custom/divr#0"

        "hyprland/workspaces"
        "custom/divr#1"
      ];
    };

    # dividers (left -> right)
    "custom/divr#0" =
      waybar_lib.div.r
      // {
        signal = 8;
        exec = "${divr-gws0}";
        interval = "once";
        return-type = "json";
      };
    "custom/divr#1" = waybar_lib.div.r;
  };

  my.waybar.styles = {
    parts =
      /*
      css
      */
      ''
        #gworkspaces #custom-divr.0 {
          background-color: @mantle;
        }

        #gworkspaces #custom-divr.1 {
          color: @mantle;
        }

        /* below are coloured as scratchpad */
        #gworkspaces #custom-divr.0.active {
          color: @scratchpad-bg-active;
        }

        #gworkspaces #custom-divr.0.inactive {
          color: @scratchpad-bg-inactive;
        }
      '';
  };
}
