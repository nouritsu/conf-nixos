{pkgs, ...}: {
  wayland.windowManager.hyprland.settings.exec-once = [
    "gnome-keyring-daemon --start --components=secrets,pkcs11,ssh"
  ];

  home.packages = [
    pkgs.gcr_4
    pkgs.seahorse
  ];
}
