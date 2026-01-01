{
  lib,
  config,
  ...
}: let
  is_grub = config.my.boot.loader == "grub";
in
  lib.mkIf is_grub {
    boot.loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };

    catppuccin.grub.enable = true;
  }
