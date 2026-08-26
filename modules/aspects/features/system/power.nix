{
  den.aspects.power = {
    nixos = {pkgs, ...}: {
      # power-profiles-daemon, not TLP — DMS drives the profile switcher
      # over its D-Bus interface, and the two conflict if both are on.
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

      # Suspend on lid close whether or not it is plugged in; ignore it
      # while docked, since an external monitor means lid-shut use.
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

    # Intel-only thermal daemon; keeps the package off AMD hosts.
    provides.thermald.nixos = {
      services.thermald.enable = true;
    };
  };
}
