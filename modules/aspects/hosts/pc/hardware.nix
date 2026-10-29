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

    # cachyos defaults to 0 for zram; this swap is on disk behind zswap
    boot.kernel.sysctl."vm.page-cluster" = 3;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
