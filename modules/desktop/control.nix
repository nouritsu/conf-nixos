{
  flake.nixosModules.desktop-control = {pkgs, ...}: {
    my.hmModules = ["desktop-control"];

    environment.systemPackages = with pkgs; [
      pavucontrol
      blueman
      brightnessctl
      networkmanager
      networkmanagerapplet
    ];
  };

  flake.homeModules.desktop-control = {...}: {
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, A, exec, pavucontrol"
      "SUPER, B, exec, blueman-manager"
      "SUPER, N, exec, nm-connection-editor"
    ];

    wayland.windowManager.hyprland.settings.windowrule = let
      m_pavu = "match:class org\.pulseaudio\.pavucontrol";
      m_blueman = "match:class \.blueman\-manager\-wrapped";
      m_nm = "match:class nm\-connection\-editor";
    in [
      "float on, ${m_pavu}"
      "center on, ${m_pavu}"
      "size (monitor_w/2.5) (monitor_h/2.5), ${m_pavu}"

      "float on, ${m_blueman}"
      "center on, ${m_blueman}"
      "size (monitor_w/2.5) (monitor_h/2.5), ${m_blueman}"

      "float on, ${m_nm}"
      "center on, ${m_nm}"
      "size (monitor_w/2.5) (monitor_h/2.5), ${m_nm}"
    ];
  };
}
