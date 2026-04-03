{
  flake.nixosModules.wniri-keybinds = {lib, ...}: let
    mk_directional_bind = dir: bind: let
      keys =
        {
          left = ["H" "left"];
          right = ["L" "right"];
          up = ["K" "up"];
          down = ["J" "down"];
        }.${
          dir
        };
      replacePlaceholder = str: replacement: lib.replaceStrings ["%d"] [replacement] str;
      mkBind = key:
        lib.mapAttrs' (
          k: v:
            lib.nameValuePair
            (replacePlaceholder k key)
            (
              if lib.isAttrs v
              then lib.mapAttrs' (cmd: val: lib.nameValuePair (replacePlaceholder cmd dir) val) v
              else v
            )
        )
        bind;
    in
      lib.foldl' lib.mergeAttrs {} (map mkBind keys);

    mk_lr_bind = bind: (mk_directional_bind "left" bind) // (mk_directional_bind "right" bind);
    mk_ud_bind = bind: (mk_directional_bind "up" bind) // (mk_directional_bind "down" bind);
    mk_lrdu_bind = bind: (mk_lr_bind bind) // (mk_ud_bind bind);
  in {
    settings.layout = {
      preset-column-widths = [
        {proportion = 1.0 / 3.0;}
        {proportion = 0.5;}
        {proportion = 2.0 / 3.0;}
      ];
    };

    settings.binds = let
      win_focus =
        (mk_lr_bind {"Mod+%d"."focus-column-%d" = _: {};})
        // (mk_ud_bind {"Mod+%d"."focus-window-or-workspace-%d" = _: {};});

      win_move =
        (mk_lr_bind {"Mod+Shift+%d"."move-column-%d" = _: {};})
        // (mk_ud_bind {"Mod+Shift+%d"."move-window-to-workspace-%d" = _: {};});

      ws_focus = lib.foldl' lib.mergeAttrs {} (map (n: {
        "Mod+${toString n}"."focus-workspace" = n;
      }) (lib.range 1 9));

      ws_move = lib.foldl' lib.mergeAttrs {} (map (n: {
        "Mod+Shift+${toString n}"."move-column-to-workspace" = n;
      }) (lib.range 1 9));
    in
      {
        "Mod+Q".close-window = _: {};

        "Mod+C".center-visible-columns = _: {};
        "Mod+Shift+C".center-window = _: {};

        "Mod+F".fullscreen-window = _: {};
        "Mod+Shift+F".toggle-window-floating = _: {};

        "Mod+R".switch-preset-column-width = _: {};

        "Mod+M".maximize-column = _: {};
        "Mod+Shift+M"."expand-column-to-available-width" = _: {};

        "Mod+Tab".toggle-overview = _: {};

        "Mod+WheelScrollDown".focus-column-left = _: {};
        "Mod+WheelScrollUp".focus-column-right = _: {};
        "Mod+Shift+WheelScrollDown".focus-workspace-down = _: {};
        "Mod+Shift+WheelScrollUp".focus-workspace-up = _: {};
      }
      // win_focus // win_move // ws_focus // ws_move;
  };
}
