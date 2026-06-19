{self, ...}: {
  flake.nixosModules.desktop-control = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      self.packages.${system}.hyprlock
      pavucontrol
      blueman
      brightnessctl
      networkmanager
      networkmanagerapplet
    ];
  };
}
