{usrconf, ...}: {
  programs.hyprshot = {
    enable = true;
    saveLocation = "/home/${usrconf.user.alias}/img/screenshots";
  };
}
