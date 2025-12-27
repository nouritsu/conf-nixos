{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    kernelModules = ["nct6775" "k10temp"];
  };
}
