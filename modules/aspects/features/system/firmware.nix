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

    updates.nixos = {
      services.fwupd.enable = true;
    };
  };
}
