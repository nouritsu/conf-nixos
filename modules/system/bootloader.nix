{inputs, ...}: {
  flake.nixosModules.bootloader = {pkgs, ...}: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    boot.loader.systemd-boot = {
      enable = false;

      windows."11" = {
        title = "Windows 11";
        efiDeviceHandle = "HD1b";
        sortKey = "y_windows";
      };

      edk2-uefi-shell = {
        enable = true;
        sortKey = "z_shell";
      };
    };

    boot.loader.efi.canTouchEfiVariables = true;

    # sbctl: Secure Boot key management
    environment.systemPackages = [pkgs.sbctl];
  };
}
