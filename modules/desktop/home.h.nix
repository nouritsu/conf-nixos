{
  imports = [
    ## auth
    ./modules/auth/polkit.h.nix
    ./modules/auth/keyring.h.nix
    ## clipboard
    ./modules/clipboard/clipse.h.nix
    ## compability
    ./modules/compability/electron-ozone.h.nix
    ./modules/compability/qt.h.nix
    ./modules/compability/xdg.h.nix
    ## control
    ./modules/control/audio.h.nix
    ./modules/control/blueman.h.nix
    ./modules/control/brightness.h.nix
    ./modules/control/dconf.h.nix
    ./modules/control/networkmanager.h.nix
    ## cursor
    ./modules/cursor/cursor.h.nix
    ## extra
    ./modules/extra/hyprpicker.h.nix
    ./modules/extra/phone-view.h.nix
    ## filesystem
    ./modules/filesystem/explorer.h.nix
    ## gaming
    ./modules/gaming/steam/home.h.nix
    ## hyprland
    ./modules/hyprland/home.h.nix
    ## media
    ./modules/media/music.h.nix
    ./modules/media/office.h.nix
    ./modules/media/pdf.h.nix
    ## menu
    ./modules/menu/walker.h.nix
    ## notification
    ./modules/notification/swaync.h.nix
    ## peripherals
    ./modules/peripherals/keyboard.h.nix
    ./modules/peripherals/monitor.h.nix
    ./modules/peripherals/mouse.h.nix
    ./modules/peripherals/touchpad.h.nix
    ## productivity
    ./modules/productivity/notes.h.nix
    ./modules/productivity/wezterm.h.nix
    ./modules/productivity/zed.h.nix
    ## screencapture
    ./modules/screencapture/broadcast.h.nix
    ./modules/screencapture/screenshot.h.nix
    ## session
    ./modules/session/hyprlock.h.nix
    ./modules/session/wleave.h.nix
    ## wallpaper
    ./modules/wallpaper/home.h.nix
    ## waybar
    ./modules/waybar/home.h.nix
    ## web
    ./modules/web/communication.h.nix
    ./modules/web/firefox.h.nix
    ## zoom
    ./modules/zoom/woomer.h.nix
  ];
}
