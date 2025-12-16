{
  inputs,
  pkgs,
  lib,
  usrconf,
  ...
}: let
  hyprcwd = "${inputs.hyprcwd-rs.packages.${usrconf.system}.default}/bin/hyprcwd";
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
        ",preferred,auto,1.25"
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

      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "NIXOS_OZONE_WL,1"
      ];

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(nm-connection-editor)$"
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"

        # Waybar module terminals
        "float,class:^(waybar-power-menu)$"
        "center,class:^(waybar-power-menu)$"
        "size 400 300,class:^(waybar-power-menu)$"

        "float,class:^(waybar-network)$"
        "center,class:^(waybar-network)$"
        "size 600 400,class:^(waybar-network)$"

        "float,class:^(waybar-bluetooth)$"
        "center,class:^(waybar-bluetooth)$"
        "size 600 400,class:^(waybar-bluetooth)$"
      ];

      bind =
        [
          "SUPER, T, exec, ${terminal}"
          "SUPER, RETURN, exec, ${terminal-cwd}"
          "SUPER, W, exec, ${browser}"
          "SUPERSHIFT, W, exec, swww-change-wallpaper"
          "SUPER, E, exec, ${explorer}"
          "SUPER, SUPER_L, exec, ${menu}"
          "SUPER, ESCAPE, exec, hyprlock"
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
