{den, ...}: {
  den.aspects.desktop.includes = with den.aspects; [
    graphics
    graphics.nvidia
    audio
    audio.fx
    audio.rtkit
    audio.mixer
    bluetooth
    peripherals.keyboard
    peripherals.monitor
    peripherals.tablet
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
