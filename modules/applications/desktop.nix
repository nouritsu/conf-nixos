{
  flake.nixosModules.desktop = {pkgs, ...}: {
    my.hmModules = ["desktop"];

    environment.systemPackages = with pkgs; [
      pavucontrol
      blueman
      brightnessctl
      dconf
      networkmanager
      networkmanagerapplet
    ];

    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
    };
  };

  flake.homeModules.desktop = {
    pkgs,
    lib,
    ...
  }: {
    home.pointerCursor = lib.mkForce {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
      gtk.enable = true;
      hyprcursor = {
        enable = true;
        size = 24;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    xdg.portal.config.common.default = ["hyprland" "gtk"];
    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';

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
