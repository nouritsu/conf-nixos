{inputs, ...}: {
  den.aspects.bootloader = {
    nixos = {
      boot.loader.efi.canTouchEfiVariables = true;
    };

    provides = {
      # needs sbctl create-keys + enroll-keys in Setup Mode first
      lanzaboote.nixos = {pkgs, ...}: {
        imports = [inputs.lanzaboote.nixosModules.lanzaboote];

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        boot.loader.systemd-boot.enable = false;

        environment.systemPackages = [pkgs.sbctl];
      };

      grub.nixos = {
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          device = "nodev"; # EFI only, no MBR
        };
      };

      systemd-boot.nixos = {
        boot.loader.systemd-boot.enable = true;
      };

      # GRUB only
      os-prober.nixos = {
        boot.loader.grub.useOSProber = true;
      };
    };
  };
}
