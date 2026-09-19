{den, ...}: {
  den.aspects.development.includes = with den.aspects; [
    dev
    dev.direnv
    dev.android
    dev.c
    dev.embedded
    dev.nix
    dev.python
    dev.rust
    git
    helix
    virtualization.podman
    virtualization.emulate-aarch64
  ];
}
