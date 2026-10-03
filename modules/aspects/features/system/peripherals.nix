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
      nixos = {
        config,
        pkgs,
        ...
      }: let
        # 3.12.4 lacks the Viper V4 Pro; openrazer#2751 until a release has it
        src = pkgs.fetchFromGitHub {
          owner = "openrazer";
          repo = "openrazer";
          rev = "1f25202a06fc9d37a2475ce71cc0b68fa6bff96c";
          hash = "sha256-6l1P7Cmx9FwhXAnIss6K7Wpt4nkg861WrgItViD+8Hs=";
        };
        version = "3.12.4-unstable-2026-07-12";
      in {
        hardware.openrazer = {
          enable = true;
          packages.kernel = config.boot.kernelPackages.openrazer.overrideAttrs {
            inherit src;
            version = "${version}-${config.boot.kernelPackages.kernel.version}";
          };
          packages.daemon = pkgs.python3Packages.openrazer-daemon.overridePythonAttrs {
            inherit src version;
          };
        };

        environment.systemPackages = [pkgs.polychromatic];
      };

      user.extraGroups = ["openrazer" "plugdev"];
    };
  };
}
