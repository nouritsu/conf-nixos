{
  den.aspects.power = {
    nixos = {pkgs, ...}: {
      # ppd, not TLP: DMS needs ppd and the two conflict
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };

      environment.systemPackages = [
        pkgs.brightnessctl
        pkgs.powertop
      ];
    };

    # Intel only
    provides.thermald.nixos = {
      services.thermald.enable = true;
    };
  };
}
