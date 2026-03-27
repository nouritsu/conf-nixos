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
        (mk_lr_bind {"Mod+%d"."focus-column-%d" = null;})
        // (mk_ud_bind {"Mod+%d"."focus-window-or-workspace-%d" = null;});

      win_move =
        (mk_lr_bind {"Mod+Shift+%d"."move-column-%d" = null;})
        // (mk_ud_bind {"Mod+Shift+%d"."move-window-to-workspace-%d" = null;});

      ws_focus = lib.foldl' lib.mergeAttrs {} (map (n: {
        "Mod+${toString n}"."focus-workspace" = n;
      }) (lib.range 1 9));

      ws_move = lib.foldl' lib.mergeAttrs {} (map (n: {
        "Mod+Shift+${toString n}"."move-column-to-workspace" = n;
      }) (lib.range 1 9));
    in
      {
        "Mod+Q".close-window = null;

        "Mod+C".center-visible-columns = null;
        "Mod+Shift+C".center-window = null;

        "Mod+F".fullscreen-window = null;
        "Mod+Shift+F".toggle-window-floating = null;

        "Mod+R".switch-preset-column-width = null;

        "Mod+M".maximize-column = null;
        "Mod+Shift+M"."expand-column-to-available-width" = null;

        "Mod+Tab".toggle-overview = null;
      }
      // win_focus // win_move // ws_focus // ws_move;
  };
}
