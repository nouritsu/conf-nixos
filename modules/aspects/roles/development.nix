{den, ...}: {
  den.aspects.development.includes = with den.aspects; [
    dev
    dev.direnv
    dev.devenv
    dev.android
    dev.embedded
    dev.godot
    dev.nix
    dev.python
    git
    helix
    virtualization.podman
  ];
}
