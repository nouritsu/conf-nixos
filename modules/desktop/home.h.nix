{
  imports = [
    # by-utility
    ## extra
    ./mod/by-utility/extra/hyprpicker.h.nix
    ./mod/by-utility/extra/phone-view.h.nix
    ## filesystem
    ./mod/by-utility/filesystem/explorer.h.nix
    ## gaming
    ./mod/by-utility/gaming/steam/home.h.nix
    ## media
    ./mod/by-utility/media/music.h.nix
    ./mod/by-utility/media/office.h.nix
    ./mod/by-utility/media/pdf.h.nix
    ## productivity
    ./mod/by-utility/productivity/notes.h.nix
    ./mod/by-utility/productivity/wezterm.h.nix
    ./mod/by-utility/productivity/zed.h.nix
    ## screencapture
    ./mod/by-utility/screencapture/broadcast.h.nix
    ./mod/by-utility/screencapture/screenshot.h.nix
    ## web
    ./mod/by-utility/web/communication.h.nix
    ./mod/by-utility/web/firefox.h.nix
    ## zoom
    ./mod/by-utility/zoom/woomer.h.nix

    # core
    ## auth
    ./mod/core/auth/polkit.h.nix
    ## compability
    ./mod/core/compability/electron-ozone.h.nix
    ./mod/core/compability/qt.h.nix
    ./mod/core/compability/xdg.h.nix
    ## control
    ./mod/core/control/audio.h.nix
    ./mod/core/control/blueman.h.nix
    ./mod/core/control/brightness.h.nix
    ./mod/core/control/dconf.h.nix
    ./mod/core/control/networkmanager.h.nix
    ## cursor
    ./mod/core/cursor/cursor.h.nix
    ## hyprland
    ./mod/core/hyprland/home.h.nix
    ## menu
    ./mod/core/menu/walker.h.nix
    ## notification
    ./mod/core/notification/swaync.h.nix
    ## peripherals
    ./mod/core/peripherals/keyboard.h.nix
    ./mod/core/peripherals/monitor.h.nix
    ./mod/core/peripherals/mouse.h.nix
    ./mod/core/peripherals/touchpad.h.nix
    ## session
    ./mod/core/session/hyprlock.h.nix
    ./mod/core/session/wleave.h.nix
    ## wallpaper
    ./mod/core/wallpaper/home.h.nix
    ## waybar
    ./mod/core/waybar/home.h.nix
  ];
}
