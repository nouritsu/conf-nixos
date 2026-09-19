{den, ...}: {
  den.aspects.peripherals.provides = {
    keyboard = {
      includes = [(den.batteries.unfree ["wootility"])];
      nixos = {pkgs, ...}: {
        console.keyMap = "us";
        services.xserver.xkb.layout = "eu";

        # Wooting 60HE configuration software
        environment.systemPackages = [pkgs.wootility];
        services.udev.packages = [pkgs.wooting-udev-rules];
      };
    };

    monitor = {
      nixos = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.ddcutil
          pkgs.i2c-tools
        ];

        services.ddccontrol = {
          enable = true;
          package = pkgs.ddcutil-service;
        };

        hardware.i2c.enable = true;
      };

      user.extraGroups = ["i2c"];
    };

    tablet = {
      nixos = {
        hardware.opentabletdriver.enable = true;
        hardware.uinput.enable = true;

        services.udev.extraRules = ''
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
        '';
      };

      user.extraGroups = ["input"];
    };

    controller = {
      includes = [(den.batteries.unfree ["xone-dongle-firmware"])];
      nixos = {pkgs, ...}: {
        hardware.xpadneo.enable = true; # Xbox One/Series over Bluetooth
        hardware.xone.enable = true; # Xbox One/Series over dongle + USB
        hardware.steam-hardware.enable = true; # Steam controller + generic gamepad

        environment.systemPackages = [
          pkgs.linuxConsoleTools
          pkgs.antimicrox
        ];

        services.udev.packages = [pkgs.game-devices-udev-rules];
      };

      user.extraGroups = ["input"];
    };

    razer = {
      nixos = {pkgs, ...}: {
        hardware.openrazer.enable = false;

        environment.systemPackages = [
          pkgs.openrazer-daemon
          pkgs.polychromatic
        ];
      };

      user.extraGroups = ["openrazer" "plugdev"];
    };
  };
}
