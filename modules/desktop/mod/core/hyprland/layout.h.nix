{lib, ...}: let
  # Binds
  movefocus_binds = directional_bind "SUPER" "movefocus";
  swapwindow_binds = directional_bind "SUPERSHIFT" "swapwindow";

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
  wayland.windowManager.hyprland.settings = {
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    bind =
      movefocus_binds
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
  };
}
