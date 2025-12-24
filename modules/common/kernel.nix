{pkgs, ...}: {
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
}
