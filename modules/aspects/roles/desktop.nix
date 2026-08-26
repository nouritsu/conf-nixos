{den, ...}: {
  den.aspects.desktop.includes = with den.aspects; [
    graphics
    audio
    audio.fx
    audio.rtkit
    audio.mixer
    bluetooth
    niri
    niri.portals
    niri.xwayland
    dms
    greeter
    lock
    core
    catppuccin
    stylix
    stylix.catppuccin
    extra.fetchers
    extra.tui-viewers
  ];
}
