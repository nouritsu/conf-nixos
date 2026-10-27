# shared by the perSystem and host pkgs, which have to agree since
# aspects install wrappers built with the perSystem one
inputs: [
  inputs.cachyos-kernel.overlays.pinned
  inputs.niri.overlays.default
  (import ./niri.nix)
  (import ./mcp-nixos.nix)
  # hide-from-own-capture
  inputs.shatterlock.overlays.niri
  inputs.millennium.overlays.default
]
