{inputs, ...}: {
  den.aspects.bootloader = {
    # Common to every EFI host; the actual loader comes from a provide.
    nixos = {
      boot.loader.efi.canTouchEfiVariables = true;
    };

    provides = {
      # Signed boot chain. Needs `sbctl create-keys` + `sbctl enroll-keys`
      # with the firmware in Setup Mode before the host will boot.
      lanzaboote.nixos = {pkgs, ...}: {
        imports = [inputs.lanzaboote.nixosModules.lanzaboote];

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        # lanzaboote replaces systemd-boot as the bootloader.
        boot.loader.systemd-boot.enable = false;

        environment.systemPackages = [pkgs.sbctl];
      };

      grub.nixos = {
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          device = "nodev"; # EFI install into the ESP, not an MBR
        };
      };

      systemd-boot.nixos = {
        boot.loader.systemd-boot.enable = true;
      };

      # Detect other installed OSes and add them to the boot menu.
      # GRUB-only, and needs the other OS's partition to be discoverable.
      os-prober.nixos = {
        boot.loader.grub.useOSProber = true;
      };
    };
  };
}
