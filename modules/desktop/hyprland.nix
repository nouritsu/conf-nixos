{inputs, ...}: {
  flake.nixosModules.desktop-hyprland = {pkgs, ...}: {
    my.hmModules = ["desktop-hyprland"];

    catppuccin.gtk.icon.enable = true;

    environment.systemPackages = [
      pkgs.dconf
    ];

    environment.variables = {
      NIXOS_OZONE_WL = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    };
  };

  flake.homeModules.desktop-hyprland = {
    osConfig,
    lib,
    ...
  }: let
    workspaces = 5;
    workspaces_strs = map toString (lib.range 1 workspaces);

    # Binds
    movefocus_binds = directional_bind "SUPER" "movefocus";
    swapwindow_binds = directional_bind "SUPERSHIFT" "swapwindow";
    switch_ws_binds = map (w: "SUPER, ${w}, workspace, ${w}") workspaces_strs;
    move_to_ws_binds = map (w: "SUPERSHIFT, ${w}, movetoworkspace, ${w}") workspaces_strs;
    special_ws_binds = [
      "SUPER, S, togglespecialworkspace, magic"
      "SUPERSHIFT, S, movetoworkspace, special:magic"
    ];

    # Helpers
    directional_bind = modifier: dispatcher:
      lib.flatten (
        lib.mapAttrsToList (
          name: keys:
          # eg. "SUPER, H, movefocus, l"
            map (key: "${modifier}, ${key}, ${dispatcher}, ${name}") keys
        )
        {
          l = ["H" "left"];
          r = ["L" "right"];
          u = ["K" "up"];
          d = ["J" "down"];
        }
      );
  in {
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${osConfig.my.system.arch}.hyprland;
      portalPackage = inputs.hyprland.packages.${osConfig.my.system.arch}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
      systemd.enable = true;

      settings = {
        monitor = ["MAIN,preferred,auto,1"];

        input = {
          kb_layout = "eu";
          follow_mouse = 1;
          sensitivity = 1.0;
          accel_profile = "flat";
        };

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

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        gesture = [
          "3, horizontal, workspace"
        ];

        bind =
          switch_ws_binds
          ++ move_to_ws_binds
          ++ special_ws_binds
          ++ movefocus_binds
          ++ swapwindow_binds
          ++ [
            "SUPER, Q, killactive,"
            "SUPERSHIFT, Q, forcekillactive"

            "SUPER, F, fullscreen"
            "SUPERSHIFT, F, togglefloating"

            "SUPERSHIFT, T, togglesplit"
          ];

        bindm = [
          "SUPER, mouse:272, movewindow"

          "SUPER, mouse:273, resizewindow"
          "SUPERSHIFT, mouse:272, resizewindow"
        ];

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 0;
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

        decoration = {
          rounding = 12;
          active_opacity = 0.95;
          inactive_opacity = 0.7;
          blur = {
            enabled = true;
            size = 10;
            passes = 3;
            new_optimizations = true;
            noise = 0;
            brightness = 0.90;
            ignore_opacity = true;
          };
        };
      };
    };
  };
}
