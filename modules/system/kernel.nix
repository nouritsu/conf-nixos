{inputs, ...}: {
  flake.nixosModules = {
    kernel-cachyos-bore-lto = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.cachyos-kernel.overlays.pinned];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    };
  };
}
