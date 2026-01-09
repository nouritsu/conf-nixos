{lib, pkgs, ...}: let
  max-volume = toString 1.25;
  pasystray = lib.getExe pkgs.pasystray;
  pavucontrol = lib.getExe pkgs.pavucontrol;
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
in {
  home.packages = [
    pkgs.pasystray
    pkgs.pavucontrol
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    pasystray
  ];

  wayland.windowManager.hyprland.settings.bindel = [
    ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit ${max-volume}"
    ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%- --limit ${max-volume}"
    ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
  ];

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, A, exec, ${pavucontrol}"
  ];

  wayland.windowManager.hyprland.settings.windowrule = let
    match_ = "match:class org\.pulseaudio\.pavucontrol";
  in [
    "float on, ${match_}"
    "center on, ${match_}"
    "size (monitor_w/2.5) (monitor_h/2.5), ${match_}"
  ];
}
