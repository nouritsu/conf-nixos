{
  flake.nixosModules = {
    bootloader-efi = {...}: {
      boot.loader.grub.efiSupport = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };

    bootloader-grub = {...}: {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "nodev";

      # TODO: move to theming
      catppuccin.grub.enable = true;
    };

    bootloader-dual-boot = {...}: {
      boot.loader.grub.useOSProber = true;
    };
  };
}
