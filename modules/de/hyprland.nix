{inputs, usrconf, ...}: {
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${usrconf.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${usrconf.system}.xdg-desktop-portal-hyprland;
  };
}
