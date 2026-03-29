{
  flake.nixosModules.desktop-control = {pkgs, ...}: {
    my.hmModules = ["desktop-control"];

    environment.systemPackages = with pkgs; [
      pavucontrol
      blueman
      brightnessctl
      networkmanager
      networkmanagerapplet
    ];
  };

  flake.homeModules.desktop-control = {...}: {
    # TODO: NIRI RULES FOR SIZE, FLOAT
  };
}
