{
  lib,
  osConfig,
  ...
}: let
  is_laptop = osConfig.my.system.kind == "laptop";
in {
  wayland.windowManager.hyprland.settings = {
    input.touchpad = lib.mkIf is_laptop {
      natural_scroll = true;
      tap-to-click = true;
      drag_lock = true;
      disable_while_typing = true;
      scroll_factor = 0.25;
    };
  };
}
