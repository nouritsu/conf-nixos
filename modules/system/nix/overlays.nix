{
  inputs,
  lib,
  ...
}: let
  local_pkg = pkg: ../../../pkgs/${pkg}/package.nix;
in {
  nixpkgs.overlays = [
    inputs.cachyos-kernel.overlays.pinned

    # Local pkgs/pkg/package.nix
    (
      final: _:
        lib.genAttrs [
          "gpu-usage-waybar"
          "ifetch"
          "mfetch"
        ] (pkg: final.callPackage (local_pkg pkg) {})
    )
  ];
}
