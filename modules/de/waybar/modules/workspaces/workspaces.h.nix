{waybar_lib, ...}: {
  programs.waybar.settings.default."hyprland/workspaces" = {
    format = "{icon}";
    format-icons = {
      active = "";
      default = "";
      empty = "";
    };
    persistent-workspaces = {
      "*" = 5;
    };
    on-scroll-up = "hyprctl dispatch workspace e+1";
    on-scroll-down = "hyprctl dispatch workspace e-1";
    cursor = true;
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines ["workspaces-bg: @mantle" "workspaces-fg-active: @accent"];

    parts =
      /*
      css
      */
      ''
        #workspaces {
          padding: 0 1px;
          background-color: @workspaces-bg;
        }

        #workspaces button.active label,
        #workspaces button.focused label {
          font-size: 20px;
          color: @workspaces-fg-active;
        }
      '';
  };
}
