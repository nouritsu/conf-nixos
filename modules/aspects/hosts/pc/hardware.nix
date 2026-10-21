{
  den.aspects.pc.nixos = {
    lib,
    modulesPath,
    config,
    ...
  }: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/b88aad6a-c345-4f28-add2-d1a84739504d";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/A3A1-5954";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    # windows ssd, mounted on first access
    fileSystems."/mnt/windows" = {
      device = "/dev/disk/by-uuid/1880CD6580CD49C8";
      fsType = "ntfs3";
      options = [
        "uid=1000"
        "gid=100"
        "nofail"
        "x-systemd.automount"
        "x-gvfs-show"
        "x-gvfs-name=Windows"
      ];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/94a1a4b4-511b-4fa4-8caa-1ceb1929af0a";}
    ];
    # cachyos defaults to 0 for zram; this swap is on disk behind zswap
    boot.kernel.sysctl."vm.page-cluster" = 3;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
