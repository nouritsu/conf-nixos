{
  imports = [
    # auth
    modules/auth/polkit.h.nix
    modules/auth/keyring.h.nix

    # compability
    modules/compability/electron-ozone.h.nix
    modules/compability/qt.h.nix
    modules/compability/xdg.h.nix

    # control
    modules/control/audio.h.nix
    modules/control/blueman.h.nix
    modules/control/brightness.h.nix
    modules/control/dconf.h.nix
    modules/control/networkmanager.h.nix

    # cursor
    modules/cursor/cursor.h.nix

    # extra
    modules/extra/hyprpicker.h.nix
    modules/extra/phone-view.h.nix

    # filesystem
    modules/filesystem/explorer.h.nix

    # gaming
    modules/gaming/steam/home.h.nix

    # hyprland
    modules/hyprland/home.h.nix

    # media
    modules/media/eog.h.nix
    modules/media/mpv.h.nix
    modules/media/pdf.h.nix

    # peripherals
    modules/peripherals/keyboard.h.nix
    modules/peripherals/monitor.h.nix
    modules/peripherals/mouse.h.nix

    # productivity
    modules/productivity/anki.h.nix
    modules/productivity/wezterm.h.nix

    # screencapture
    modules/screencapture/broadcast.h.nix
    modules/screencapture/screenshot.h.nix

    # session
    modules/session/hyprlock.h.nix

    # web
    modules/web/communication.h.nix
    modules/web/firefox.h.nix

    # zoom
    modules/zoom/woomer.h.nix
  ];
}
