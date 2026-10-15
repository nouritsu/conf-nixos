{
  den.aspects.kernel.provides.cachyos-bore-lto.nixos = {pkgs, ...}: {
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    nh'.substituters = ["https://attic.xuyh0120.win/lantian"];
    nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
  };
}
