{
  lib,
  osConfig,
  ...
}: let
  workspaces = 5;
  workspaces_strs = map toString (lib.range 1 workspaces);

  # Binds
  switch_ws_binds = map (w: "SUPER, ${w}, workspace, ${w}") workspaces_strs;
  move_to_ws_binds = map (w: "SUPERSHIFT, ${w}, movetoworkspace, ${w}") workspaces_strs;
  special_ws_binds = [
    "SUPER, S, togglespecialworkspace, magic"
    "SUPERSHIFT, S, movetoworkspace, special:magic"
  ];
in {
  wayland.windowManager.hyprland.settings = {
    bind =
      switch_ws_binds ++ move_to_ws_binds ++ special_ws_binds;

    gesture = lib.mkIf (osConfig.my.system.kind == "laptop") [
      "3, horizontal, workspace"
    ];
  };
}
