{
  den.aspects.kernel.provides.cachyos-bore-lto.nixos = {pkgs, ...}: {
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  };
}
