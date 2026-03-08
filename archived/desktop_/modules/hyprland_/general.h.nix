{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;
      resize_on_border = true;
      allow_tearing = false;
      layout = "dwindle";
      "col.active_border" = "$mauve"; # TODO: Move to themeing
      "col.inactive_border" = "$surface0";
    };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      vrr = 0;
    };
  };
}
