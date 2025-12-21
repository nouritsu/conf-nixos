{pkgs, ...}: let
  # Binds
  volume_binds = [
    ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 2.0"
    ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- --limit 2.0"
    ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  ];

  brightness_binds = [
    ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
    ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
  ];

  screenshot_binds = [
    ",PRINT, exec, ${hyprshot} -m active -m output"
    "SUPER, PRINT, exec, ${hyprshot} -zm region"
    "SUPERALT, PRINT, exec, ${hyprshot} -zm window"
  ];

  misc_binds = [
    "SUPER, ESCAPE, exec, hyprlock"
    "SUPERSHIFT, W, exec, swww-change-wallpaper"
  ];

  # Programs
  hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
in {
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;
      resize_on_border = true;
      allow_tearing = false;
      layout = "dwindle";
      "col.active_border" = "$mauve";
      "col.inactive_border" = "$surface0";
    };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      vrr = 0;
    };

    binds = volume_binds ++ brightness_binds ++ screenshot_binds ++ misc_binds;
  };
}
