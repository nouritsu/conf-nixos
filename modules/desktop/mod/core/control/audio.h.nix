{pkgs, ...}: let
  max-volume = toString 1.25;
  pasystray = "${pkgs.pasystray}/bin/pasystray";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
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
}
