# shared by the perSystem and host pkgs, which have to agree since
# aspects install wrappers built with the perSystem one
inputs: [
  (import ./r2modman.nix)
  (import ./xwayland-satellite.nix)
  inputs.cachyos-kernel.overlays.default
]
