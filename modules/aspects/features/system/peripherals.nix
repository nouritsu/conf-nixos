{den, ...}: {
  den.aspects.peripherals.provides = {
    keyboard = {
      includes = [(den.batteries.unfree ["wootility"])];
      nixos = {
        pkgs,
        lib,
        ...
      }: {
        console.keyMap = "us";
        services.xserver.xkb.layout = "eu";

        # Wooting 60HE configuration software
        environment.systemPackages = [pkgs.wootility];
        services.udev.packages = [pkgs.wooting-udev-rules];

        which-key'.menu.s.submenu.w = {
          desc = "Wootility";
          icon = "f030c";
          cmd = lib.getExe pkgs.wootility;
          app-id = "wootility";
        };
      };
    };

    monitor = {
      nixos = {
        pkgs,
        lib,
        ...
      }: let
        wl-mirror = lib.getExe pkgs.wl-mirror;
      in {
        environment.systemPackages = [
          pkgs.ddcutil
          pkgs.i2c-tools
          (pkgs.makeDesktopItem {
            name = "mirror-main-monitor";
            desktopName = "Mirror Main Monitor";
            comment = "Mirror DP-3 into a window";
            exec = "${wl-mirror} DP-3";
            icon = "video-display";
            categories = ["Utility"];
            actions.tv = {
              name = "Fullscreen on TV";
              exec = "${wl-mirror} --fullscreen-output HDMI-A-1 DP-3";
            };
          })
        ];

        which-key'.menu.m.submenu.r = {
          desc = "Mirror main monitor";
          icon = "f1483";
          cmd = "${wl-mirror} DP-3";
          app-id = "wl_mirror";
        };

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

        which-key'.menu.s.submenu.t = {
          desc = "OpenTabletDriver";
          icon = "f19b9";
          cmd = "otd-gui";
          app-id = "opentabletdriver";
        };
      };

      user.extraGroups = ["input"];
    };

    controller = {
      includes = [(den.batteries.unfree ["xone-dongle-firmware"])];
      nixos = {
        pkgs,
        lib,
        ...
      }: {
        hardware.xpadneo.enable = true; # Xbox One/Series over Bluetooth
        hardware.xone.enable = true; # Xbox One/Series over dongle + USB
        hardware.steam-hardware.enable = true; # Steam controller + generic gamepad

        environment.systemPackages = [
          pkgs.linuxConsoleTools
          pkgs.antimicrox
        ];

        services.udev.packages = [pkgs.game-devices-udev-rules];

        which-key'.menu.g.submenu.c = {
          desc = "AntiMicroX";
          icon = "f0b82";
          cmd = lib.getExe pkgs.antimicrox;
          app-id = "antimicrox";
        };
      };

      user.extraGroups = ["input"];
    };

    razer = {
      nixos = {
        config,
        pkgs,
        lib,
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
        nixpkgsVersion = pkgs.python3Packages.openrazer-daemon.version;
        inherit (config.boot.kernelPackages) kernel;
      in {
        warnings = lib.optional (lib.versionOlder "3.12.4" nixpkgsVersion) "nixpkgs has openrazer ${nixpkgsVersion}; drop the git pin if it supports the Viper V4 Pro";

        hardware.openrazer = {
          enable = true;
          packages.kernel = config.boot.kernelPackages.openrazer.overrideAttrs (old: {
            inherit src;
            version = "${version}-${kernel.version}";

            # a WARN path from hid.h kept the 1.3 GB kernel dev tree alive
            # .ko.xz from compressing kernels can't hold the plain path
            nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.removeReferencesTo];
            postInstall =
              (old.postInstall or "")
              + ''
                find $out/lib/modules -name '*.ko' -exec remove-references-to -t ${kernel.dev} {} +
              '';
          });
          packages.daemon = pkgs.python3Packages.openrazer-daemon.overridePythonAttrs {
            inherit src version;
          };
        };
      };

      user.extraGroups = ["openrazer"];
    };
  };
}
