{pkgs, ...}: {
  services = {
    xserver = {
      displayManager.gdm.enable = true;
      dekstopManager.gnome.enable = true;
    };
    gnome.gnome-browser-connector.enable = true;
  };
}
