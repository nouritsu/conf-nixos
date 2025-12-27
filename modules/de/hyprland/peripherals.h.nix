{
  lib,
  osConfig,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
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

      touchpad = lib.mkIf (osConfig.my.system.kind == "laptop") {
        natural_scroll = true;
        tap-to-click = true;
        drag_lock = true;
        disable_while_typing = true;
        scroll_factor = 0.25;
      };
    };
  };
}
