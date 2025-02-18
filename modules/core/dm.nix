{pkgs, ...}: {
  services.xserver.displayManager = {
    gdm.enable = true;
    gnome.enable = true;
  };

  programs.dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/datetime" = {automatic-timezone = true;};
      "org/gnome/system/location" = {enabled = true;};
    };
  };

  environment = {
    environment.gnome.excludePackages = with pkgs; [
      atomix
      cheese
      epiphany
      evince
      geary
      gedit
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      hitori
      iango
      tali
      totem
    ];
    systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };
}
