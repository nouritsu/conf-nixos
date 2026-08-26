{
  den.aspects.lenovo.nixos = {
    lib,
    modulesPath,
    config,
    ...
  }: let
    # PLACEHOLDER — replace every REPLACE-ME below with the real values from
    # `nixos-generate-config --show-hardware-config` run on the laptop.
    # Until then this host builds but will not boot.
    placeholder = "REPLACE-ME";
    stillStubbed =
      lib.any (fs: lib.hasInfix placeholder fs.device)
      (lib.attrValues config.fileSystems);
  in {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    warnings = lib.optional stillStubbed ''
      modules/aspects/hosts/lenovo/hardware.nix still has placeholder disk
      UUIDs. Run `nixos-generate-config --show-hardware-config` on the
      laptop and paste the real fileSystems/swapDevices entries in.
    '';

    boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/${placeholder}";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/${placeholder}";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
