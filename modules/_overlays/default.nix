inputs: [
  inputs.cachyos-kernel.overlays.pinned
  inputs.niri.overlays.default
  (import ./niri.nix)
  (import ./mcp-nixos.nix)
  (import ./yubikey-touch-detector.nix)
  (import ./stasis.nix)
  # hide-from-own-capture
  inputs.shatterlock.overlays.niri
  inputs.millennium.overlays.default
]
