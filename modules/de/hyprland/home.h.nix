{
  inputs,
  usrconf,
  pkgs,
  ...
}: {
  imports = [
    ./appearance.h.nix
    ./applications.h.nix
    ./core.h.nix
    ./layout.h.nix
    ./peripherals.h.nix
    ./startup.h.nix
    ./workspaces.h.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${usrconf.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${usrconf.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    dconf
  ];
}
