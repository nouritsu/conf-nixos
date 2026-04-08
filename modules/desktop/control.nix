{
  flake.nixosModules.desktop-control = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      pavucontrol
      blueman
      brightnessctl
      networkmanager
      networkmanagerapplet
    ];
  };
}
