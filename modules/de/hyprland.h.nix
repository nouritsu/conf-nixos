{
  inputs,
  pkgs,
  lib,
  usrconf,
  ...
}: let
  hyprcwd = "${inputs.hyprcwd-rs.packages.${usrconf.system}.default}/bin/hyprcwd";
  hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
  menu = "${pkgs.walker}/bin/walker";

  terminal = "${pkgs.wezterm}/bin/wezterm-gui";
  terminal-cwd = "${terminal} start --cwd \$(${hyprcwd}|| echo \$HOME)";

  browser = "${pkgs.firefox}/bin/firefox";
  explorer = "${terminal-cwd} -- yazi";

  workspaces = 5;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${usrconf.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${usrconf.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      monitor = [
        "MAIN,preferred,auto,1"
      ];

      input = {
        kb_layout = "eu";
        kb_variant = "";
        kb_options = "";

        follow_mouse = 1;
        sensitivity = 1.0;
        accel_profile = "flat";

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
          disable_while_typing = true;
          scroll_factor = 0.25;
        };
      };

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

      decoration = rec {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = active_opacity;

        blur = {
          enabled = true;
          size = 3;
          passes = 3;
          new_optimizations = true;
          vibrancy = 0.1696;
          ignore_opacity = true;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];
        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "windowsIn, 1, 3, md3_decel, popin 60%"
          "windowsOut, 1, 3, md3_accel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 3, md3_decel"
          "layersIn, 1, 3, menu_decel, slide"
          "layersOut, 1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2, menu_decel"
          "fadeLayersOut, 1, 4.5, menu_accel"
          "workspaces, 1, 8, menu_decel, slide"
          "specialWorkspace, 1, 5, md3_decel, slidevert"
        ];
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      bind =
        [
          "SUPER, T, exec, ${terminal}"
          "SUPER, RETURN, exec, ${terminal-cwd}"
          "SUPER, W, exec, ${browser}"
          "SUPERSHIFT, W, exec, swww-change-wallpaper"
          "SUPER, E, exec, ${explorer}"
          "SUPER, SUPER_L, exec, ${menu}"
          "SUPER, ESCAPE, exec, hyprlock"
          ",PRINT, exec, ${hyprshot} -m active -m output"
          "SUPER, PRINT, exec, ${hyprshot} -zm region"
          "SUPERALT, PRINT, exec, ${hyprshot} -zm window"
        ]
        ++ [
          "SUPER, H, movefocus, l"
          "SUPER, J, movefocus, d"
          "SUPER, K, movefocus, u"
          "SUPER, L, movefocus, r"
          "SUPER, left, movefocus, l"
          "SUPER, down, movefocus, d"
          "SUPER, up, movefocus, u"
          "SUPER, right, movefocus, r"

          "SUPERSHIFT, H, swapwindow, l"
          "SUPERSHIFT, J, swapwindow, d"
          "SUPERSHIFT, K, swapwindow, u"
          "SUPERSHIFT, L, swapwindow, r"
          "SUPERSHIFT, left, swapwindow, l"
          "SUPERSHIFT, down, swapwindow, d"
          "SUPERSHIFT, up, swapwindow, u"
          "SUPERSHIFT, right, swapwindow, r"

          "SUPERSHIFT, T, togglesplit"

          "SUPER, F, fullscreen"
          "SUPERSHIFT, F, togglefloating"

          "SUPER, Q, killactive,"

          "SUPER, S, togglespecialworkspace, magic"
          "SUPERSHIFT, S, movetoworkspace, special:magic"

          "SUPER, G, togglegroup"
          "SUPER, TAB, changegroupactive, f"
          "SUPERSHIFT, TAB, changegroupactive, b"
          "SUPERSHIFT, G, lockgroups, toggle"
        ]
        ++ builtins.map (ws: "SUPER, ${builtins.toString ws}, workspace, ${builtins.toString ws}") (lib.range 1 workspaces)
        ++ builtins.map (ws: "SUPERSHIFT, ${builtins.toString ws}, movetoworkspace, ${builtins.toString ws}") (lib.range 1 workspaces)
        ++ [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 2.0"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- --limit 2.0"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ]
        ++ [
          ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      exec-once = [
        "wezterm-mux-server --daemonize"
      ];

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 0;
      };
    };
  };
}
