{inputs, ...}: {
  flake.nixosModules = {
    kernel-cachyos-bore-lto = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.cachyos-kernel.overlays.default];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    };
  };
}
