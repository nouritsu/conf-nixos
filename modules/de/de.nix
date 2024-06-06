{ pkgs, ... }: {
  # Enable GDM
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      model = "";
    };
  };

  # Exclude Packages
  environment.gnome.excludePackages = with pkgs.gnome; [
    cheese
    eog
    evince
    geary
    gnome-characters
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-system-monitor
    pkgs.gnome-connections
    pkgs.gnome-photos
    pkgs.gnome-tour
    seahorse
    simple-scan
    totem
    yelp
  ];

  # Extensions
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.compact-top-bar
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.dash-to-panel
    gnomeExtensions.just-perfection
    gnomeExtensions.rounded-window-corners
    gnomeExtensions.vitals
    gradience
  ];

  # Other Services
  services.gnome.gnome-remote-desktop.enable = true;
}
