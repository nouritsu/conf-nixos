{
  flake.nixosModules = {
    peripheral-keyboard = {...}: {
      console.keyMap = "us";
      services.xserver.xkb.layout = "eu";
    };

    peripheral-monitor = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.ddcutil
        pkgs.i2c-tools
      ];

      services.ddccontrol = {
        enable = true;
        package = pkgs.ddcutil-service;
      };

      hardware.i2c.enable = true;
      users.users.aneesh.extraGroups = ["i2c"];
    };

    peripheral-tablet = {...}: {
      hardware.opentabletdriver.enable = true;
      hardware.uinput.enable = true;
      users.users.aneesh.extraGroups = ["input"];

      services.udev.extraRules = ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0928", MODE="0660", GROUP="input"
      '';
    };

    peripheral-controller = {pkgs, ...}: {
      # Xbox One/Series wireless controllers over Bluetooth
      hardware.xpadneo.enable = true;
      # Xbox One/Series controllers over the wireless dongle and USB
      hardware.xone.enable = true;
      # Steam controller udev rules + generic gamepad permissions
      hardware.steam-hardware.enable = true;

      environment.systemPackages = [
        pkgs.linuxConsoleTools # jstest / jscal for testing & calibration
        pkgs.evtest # raw input event inspection
        pkgs.antimicrox # map gamepad input to keyboard/mouse
      ];

      # Broad udev rules covering DualShock/DualSense, Switch Pro, 8BitDo, etc.
      services.udev.packages = [pkgs.game-devices-udev-rules];

      users.users.aneesh.extraGroups = ["input"];
    };

    peripheral-razer = {pkgs, ...}: {
      hardware.openrazer.enable = true;

      environment.systemPackages = [
        pkgs.openrazer-daemon
        pkgs.polychromatic
      ];

      users.users.aneesh.extraGroups = ["openrazer" "plugdev"];
    };
  };
}
