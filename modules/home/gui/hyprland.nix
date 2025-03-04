{
  inputs,
  pkgs,
  lib,
  ...
}: let
  getpkg = import ../../../lib/getpkg.nix {inherit pkgs;};

  terminal = getpkg.named {
    name = "wezterm";
    bin = "wezterm-gui";
  };
  browser = getpkg.named {
    name = "google-chrome";
    bin = "google-chrome-stable --ozone-platform=wayland";
  };
  explorer = getpkg.named {
    name = "nemo-with-extensions";
    bin = "nemo";
  };
  menu = getpkg.named {
    name = "tofi";
    bin = "tofi-drun --drun-launch=true";
  };

  workspaces = 5;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
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
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
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

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      bind =
        [
          "SUPER, T, exec, ${terminal}"
          "SUPER, RETURN, exec, ${terminal}"
          "SUPER, W, exec, ${browser}"
          "SUPER, E, exec, ${explorer}"
          "SUPER, SUPER_L, exec, ${menu}"
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

          "SUPER, Q, killactive,"
        ]
        ++ builtins.map (ws: "SUPER, ${builtins.toString ws}, workspace, ${builtins.toString ws}") (lib.range 1 workspaces)
        ++ builtins.map (ws: "SUPERSHIFT, ${builtins.toString ws}, movetoworkspace, ${builtins.toString ws}") (lib.range 1 workspaces)
        ++ [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ]
        ++ [
          ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ];

      exec-once = [
        "weterm-mux-server --daemonize"
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
