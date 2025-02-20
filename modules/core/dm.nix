{...}: {
  services = {
    xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    gnome.gnome-browser-connector.enable = true;
  };
}
