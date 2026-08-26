{
  den.aspects.firmware.provides = {
    redist.nixos = {
      hardware.enableRedistributableFirmware = true;
    };

    amd.nixos = {
      hardware.cpu.amd.updateMicrocode = true;
    };

    intel.nixos = {
      hardware.cpu.intel.updateMicrocode = true;
    };

    all.nixos = {
      hardware.enableAllFirmware = true;
    };

    # UEFI/device firmware updates over LVFS — worth having on laptops,
    # where the vendor ships BIOS and Thunderbolt updates through it.
    updates.nixos = {
      services.fwupd.enable = true;
    };
  };
}
