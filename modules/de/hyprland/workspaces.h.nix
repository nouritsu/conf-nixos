{
  usrconf,
  lib,
  ...
}: let
  workspaces = 5;
  workspaces_strs = builtins.map builtins.toString (lib.range 1 workspaces);

  # Binds
  switch_ws_binds = builtins.map (w: "SUPER, ${w}, workspace, ${w}") workspaces_strs;
  move_to_ws_binds = builtins.map (w: "SUPERSHIFT, ${w}, movetoworkspace, ${w}") workspaces_strs;
  special_ws_binds = [
    "SUPER, S, togglespecialworkspace, magic"
    "SUPERSHIFT, S, movetoworkspace, special:magic"
  ];
in {
  wayland.windowManager.hyprland.settings = {
    bind =
      switch_ws_binds ++ move_to_ws_binds ++ special_ws_binds;

    gesture = lib.mkIf usrconf.touchpad [
      "3, horizontal, workspace"
    ];
  };
}
