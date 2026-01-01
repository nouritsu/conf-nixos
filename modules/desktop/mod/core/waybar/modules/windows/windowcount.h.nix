{...}: {
  programs.waybar.settings.default."hyprland/windowcount" = {
    format = "(w: {})";
    swap-icon-label = false;
  };

  my.waybar.styles.parts =
    /*
    css
    */
    ''
      #gwindows #windowcount {
        margin-left: 12px;
        margin-right: 12px;
      }

      #windowcount label {
        color: @hover-fg;
      }
    '';
}
