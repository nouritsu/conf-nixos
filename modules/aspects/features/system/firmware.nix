{
  den.aspects.firmware.provides = {
    redist.nixos = {
      hardware.enableRedistributableFirmware = true;
    };

    amd.nixos = {
      hardware.cpu.amd.updateMicrocode = true;
    };

    all.nixos = {
      hardware.enableAllFirmware = true;
    };
  };
}
