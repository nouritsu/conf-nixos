{self, ...}: {
  flake.nixosModules = {
    firmware-all = {...}: {
      imports = [
        self.nixosModules.nixpkgs-unfree
      ];

      hardware.enableAllFirmware = true;
    };

    firmware-redist = {...}: {
      hardware.enableRedistributableFirmware = true;
    };

    firmware-amd = {...}: {
      hardware.cpu.amd.updateMicrocode = true;
    };
  };
}
