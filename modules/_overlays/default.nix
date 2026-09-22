# The one overlay list, applied to both nixpkgs instances this flake builds:
# the perSystem one behind packages/ and the host one every aspect sees. They
# have to agree, because aspects pull perSystem-built wrappers across the seam
# via self'.packages -- niri, helix and hyprlock are all built against the
# first and installed by the second.
#
# A single nixpkgs.pkgs instance would be better still, but is out of reach
# here: it asserts nixpkgs.config == {}, and the writers are stylix's two
# overlays plus den's own unfree and insecure batteries, none of them ours to
# drop.
#
# Overlays are lazy, so the whole list is free on a host that forces none of
# it. cachyosKernels is one attribute that nothing evaluates unless
# kernel.cachyos-bore-lto is in the aspect tree, and it only is on pc.
inputs: [
  (import ./xwayland-satellite.nix)
  inputs.cachyos-kernel.overlays.default
]
