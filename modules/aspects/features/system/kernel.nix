{inputs, ...}: {
  den.aspects.kernel.provides.cachyos-bore-lto.nixos = {pkgs, ...}: {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.default];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  };
}
