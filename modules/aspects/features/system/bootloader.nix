{inputs, ...}: {
  den.aspects.bootloader.nixos = {pkgs, ...}: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl"; # sbctl key store (same as old)
    };

    # lanzaboote replaces systemd-boot as the bootloader.
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;

    environment.systemPackages = [pkgs.sbctl];
  };
}
