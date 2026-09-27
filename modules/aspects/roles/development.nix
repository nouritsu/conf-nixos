{den, ...}: {
  den.aspects.development.includes = with den.aspects; [
    dev
    dev.direnv
    dev.android
    dev.c
    dev.embedded
    dev.godot
    dev.nix
    dev.python
    dev.rust
    git
    helix
    zed
    virtualization.podman
    virtualization.emulate-aarch64
  ];
}
