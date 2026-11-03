{
  den.aspects.power = {
    nixos = {pkgs, ...}: {
      # ppd, not TLP: Dux needs ppd and the two conflict
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

      environment.systemPackages = [
        pkgs.brightnessctl
      ];
    };

    # Intel only
    provides.thermald.nixos = {
      services.thermald.enable = true;
    };
  };
}
