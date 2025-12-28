{...}: {
  environment.sessionVariables = {
    # NH_OS_FLAKE = "/home/${config.my.user.alias}/.config/nixos";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    NIXOS_OZONE_WL = 1;
  };
}
