{
  inputs,
  osConfig,
  ...
}: {
  imports = [
    ./general.h.nix
    ./layout.h.nix
    ./appearance.h.nix
    ./workspace.h.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${osConfig.my.system.arch}.hyprland;
    portalPackage = inputs.hyprland.packages.${osConfig.my.system.arch}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd.enable = true;
  };
}
