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
    dms.tailscale
    greeter
    user-dirs
    core
    nautilus
    brave
    homelab
    catppuccin
    fonts
    dms.theming
    extra.fetchers
    extra.tui-viewers
  ];
}
